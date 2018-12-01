# Class: vision_mysql::mariadb
# ===========================

class vision_mysql::mariadb (

  String $root_password,
  String $package_name = 'mariadb-server',
  Hash $backup = {},
  String $ipaddress = $::ipaddress,
  Boolean $ldap = false,
  Boolean $tls  = false,
  Boolean $cluster = false,
  Optional[Array] $cluster_nodes,
  Optional[String] $cluster_name,
  Optional[String] $server_cert = undef,
  Optional[String] $server_key = undef,
  Optional[String] $ca_cert = undef,

) {

  # empty, for future use such as chars sets, ...
  $default_override_options = {}

  if $tls {
    file { '/etc/mysql/ca-cert.pem':
      ensure  => present,
      content => $ca_cert,
    }

    file { '/etc/mysql/server-key.pem':
      ensure  => present,
      mode    => '0600',
      content => $server_key,
    }

    file { '/etc/mysql/server-cert.pem':
      ensure  => present,
      content => $server_cert,
    }

    $ssl_override_options = {
      'mysqld' => {
        'ssl'         => true,
        'ssl-ca'      => '/etc/mysql/ca-cert.pem',
        'ssl-cert'    => '/etc/mysql/server-cert.pem',
        'ssl-key'     => '/etc/mysql/server-key.pem',
      }
    }
  }
  else {
    $ssl_override_options = {}
  }

  if $ldap {
    contain '::vision_mysql::server::ldap'
    $ldap_override_options = {
      'mariadb' => {
        'plugin-load'              => 'auth_pam.so',
        'pam_use_cleartext_plugin' => true
      }
    }
  } else {
    $ldap_override_options = {}
  }

  if $cluster {
    $cluster_override_options = {
      'mysqld' => {
        'wsrep_on'                 => 'ON',
        'wsrep_provider'           => '/usr/lib/galera/libgalera_smm.so',
        'wsrep_cluster_name'       => $cluster_name,
        'wsrep_cluster_address'    => "gcomm://${ $cluster_nodes.join(',') }",
        'wsrep_sst_method'         => 'rsync',
        'wsrep_node_address'       => $ipaddress,
        'binlog_format'            => 'ROW',
        'default_storage_engine'   => 'innodb',
        'innodb_autoinc_lock_mode' => '2',
        'innodb_doublewrite'       => '1',
      }
    }
  } else {
    $cluster_override_options = {}
  }

  class { '::mysql::server':
    root_password           => $root_password,
    package_name            => $package_name,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => deep_merge(
      $default_override_options,
      $ldap_override_options,
      $ssl_override_options,
      $cluster_override_options,
      ),
  }

  class { '::mysql::client':
    package_name => 'mariadb-client',
  }

  if ! empty($backup) {
    class { '::vision_mysql::server::backup::client':
      password  => $backup['password'],
      databases => $backup['databases'],
    }
  }
}
