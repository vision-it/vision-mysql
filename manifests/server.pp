# Class: vision_mysql::server
# ===========================

# Manage MariaDB Installation

class vision_mysql::server (

  Sensitive[String] $root_password,
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

  $default_override_options = {
    'mysqld' => {
      'bind-address' => '0.0.0.0',
      'sql-mode'     => 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION',
    }
  }

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


  if $cluster_nodes {

    package { 'mariadb-backup':
      ensure  => present,
    }

    mysql_user{ 'mariabackup@%':
      ensure        => present,
      password_hash => mysql::password($cluster_password.unwrap),
      plugin        => 'mysql_native_password',
    }

    mysql_grant{ 'mariabackup@%/*.*':
      user       => 'mariabackup@%',
      table      => '*.*',
      privileges => ['RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT'],
      require    => Mysql_user['mariabackup@%'],
    }

    $cluster_override_options = {
      'mysqld' => {
        'wsrep_on'                 => 'ON',
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
        'innodb_doublewrite'       => '1'
      }
    }
  } else {
    $cluster_override_options = {}
  }

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

}
