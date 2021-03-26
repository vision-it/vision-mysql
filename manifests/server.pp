# Class: vision_mysql::server
# ===========================
#
# Manage MariaDB Installation
#
# Parameters
# ----------
#
# @param root_password Password for root user
# @param backup_password Password for backup creation user
# @param package_name Server package name
# @param ipaddress Bind Address
# @param cluster_name Name of Galera Cluster (optional)
# @param cluster_nodes List of Galera Cluster Nodes (optional)
# @param cluster_password Galera Cluster Replication Password (optional)
# @param cert TLS Certificate (optional)
# @param key TLS Private Key (optional)
# @param ca_cert TLS CA Certificate Key (optional)
#
# Examples
# --------
#
# @example
# contain ::vision_mysql::server
#

class vision_mysql::server (

  Sensitive[String] $root_password,
  Sensitive[String] $backup_password = Sensitive(fqdn_rand_string(32)),
  String $package_name = 'mariadb-server',
  String $ipaddress = $::ipaddress,
  # These variables are just for the CI pipeline
  Boolean $service_manage  = true,
  Boolean $service_enabled = true,
  # Cluster
  Optional[String] $cluster_name = undef,
  Optional[Array] $cluster_nodes = undef,
  Optional[Sensitive] $cluster_password = Sensitive(''),
  # TLS
  Optional[String] $cert = undef,
  Optional[String] $key = undef,
  Optional[String] $ca_cert = undef,

) {

  # Default options, the rest gets merged with this Hash
  $default_override_options = {
    'mysqld' => {
      'bind-address' => '0.0.0.0',
      'sql-mode'     => 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION',
    }
  }

  # Create TLS config if the TLS private key is provided
  if $key {
    class { '::vision_mysql::config::tls':
      cert    => $cert,
      key     => $key,
      ca_cert => $ca_cert,
      require => Class['mysql::server'],
    }

    $ssl_override_options = {
      'mysqld' => {
        'ssl'         => true,
        'ssl-ca'      => '/etc/mysql/ca-cert.pem',
        'ssl-cert'    => '/etc/mysql/cert.pem',
        'ssl-key'     => '/etc/mysql/key.pem',
      }
    }
  }
  else {
    $ssl_override_options = {}
  }

  # Create Galera config if cluster nodes are provided
  if $cluster_nodes {

    # Used for Replication
    package { 'mariadb-backup':
      ensure  => present,
    }

    mysql_user{ 'mariabackup@%':
      ensure        => present,
      password_hash => mysql::password($cluster_password.unwrap),
      require       => Package['mariadb-backup'],
    }

    mysql_grant{ 'mariabackup@%/*.*':
      user       => 'mariabackup@%',
      table      => '*.*',
      privileges => ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT'],
      require    => Mysql_user['mariabackup@%'],
    }

    # Turn off clustering when we only have one node, this makes testing easier.
    if length($cluster_nodes) > 1 { $wsrep_on = 'ON' } else { $wsrep_on = 'OFF' }

    $cluster_override_options = {
      'mysqld' => {
        'wsrep_on'                 => $wsrep_on,
        'wsrep_provider'           => '/usr/lib/galera/libgalera_smm.so',
        'wsrep_cluster_name'       => $cluster_name,
        'wsrep_cluster_address'    => "gcomm://${ $cluster_nodes.join(',') }",
        'wsrep_sst_method'         => 'mariabackup',
        'wsrep_node_address'       => $ipaddress,
        'wsrep_sst_auth'           => "mariabackup:${cluster_password.unwrap}",
        'wsrep_replicate_myisam'   => 'ON',
        'binlog_format'            => 'ROW',
        'default_storage_engine'   => 'innodb',
        'innodb_autoinc_lock_mode' => '2',
        'innodb_doublewrite'       => '1',
      }
    }
  } else {
    $cluster_override_options = {}
  }

  # Merging all configs together
  $override_options = deep_merge(
    $default_override_options,
    $ssl_override_options,
    $cluster_override_options
  )

  class { '::mysql::server':
    package_name            => $package_name,
    root_password           => $root_password.unwrap,
    remove_default_accounts => true,
    restart                 => true,
    service_manage          => $service_manage,
    service_enabled         => $service_enabled,
    override_options        => $override_options,
  }

  # Creates daily mysqldump
  class { '::mysql::server::backup':
    backupuser        => 'backup',
    backuppassword    => $backup_password.unwrap,
    backupdir         => '/root/sql-backup',
    file_per_database => true,
    maxallowedpacket  => '16M',
  }

  # Small helper script to create databases and users
  file { '/root/init-db.sh':
    ensure  => present,
    mode    => '0740',
    content => file('vision_mysql/init-db.sh'),
  }

}
