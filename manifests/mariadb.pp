# Class: vision_mysql::mariadb
# ===========================

class vision_mysql::mariadb (

  String $root_password,
  String $package_name = 'mariadb-server',
  Hash   $backup = {},
  String $ipaddress = $::ipaddress,
  Boolean $ldap = false,
  Boolean $tls  = false,
  Boolean $cluster = false,
  Boolean $manage_repo = false,
  Boolean $service_manage  = false,
  Boolean $service_enabled = false,
  Optional[Array] $cluster_nodes = undef,
  Optional[String] $cluster_name = undef,
  Optional[String] $server_cert = undef,
  Optional[String] $server_key = undef,
  Optional[String] $ca_cert = undef,

) {

  if $manage_repo {
    contain vision_mysql::repo::mariadb
  }

  $default_override_options = {
    'mysqld' => {
      'bind-address' => '0.0.0.0',
      'sql-mode'     => 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION',
    }
  }

  if $tls {
    class { '::vision_mysql::server::tls':
      server_cert => $server_cert,
      server_key  => $server_key,
      ca_cert     => $ca_cert
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
        'innodb_doublewrite'       => '1'
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
    service_manage          => $service_manage,
    service_enabled         => $service_enabled,
    override_options        => deep_merge(
      $default_override_options,
      $ldap_override_options,
      $ssl_override_options,
      $cluster_override_options
      )
  }

  class { '::mysql::client':
    package_name => 'mariadb-client'
  }

  if ! empty($backup) {
    class { '::vision_mysql::server::backup':
      password  => $backup['password'],
      databases => $backup['databases']
    }
  }
}
