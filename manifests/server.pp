# Class: vision_mysql
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_mysql
#

class vision_mysql::server (

  String $root_password,
  String $package_name = 'mysql-server',
  Hash   $monitoring   = {},
  Hash   $backup       = {},
  Boolean $ldap = false,
  Boolean $tls  = false,
  Optional[String] $server_cert = undef,
  Optional[String] $server_key = undef,
  Optional[String] $ca_cert = undef,

) {

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
        'ssl-ca'      => '/etc/mysq/ca-cert.pem',
        'ssl-cert'    => '/etc/mysql/server-cert.pem',
        'ssl-key'     => '/etc/mysql/server-key.pem',
      }
    }
  }
  else {
    $ssl_override_options = {}
  }

  $default_override_options = {
    'client' => {
      'default-character-set' => 'utf8',
    },
    'mysql'  => {
      'default-character-set' => 'utf8',
    },
    'mysqld' => {
      'bind-address'         => '0.0.0.0',
      'collation-server'     => 'utf8_general_ci',
      'character-set-server' => 'utf8',
      'init-connect'         => 'SET NAMES utf8',
    },
    'mariadb' => {
      'plugin-load'          => 'auth_pam.so'
    }
  }

  class { '::mysql::server':
    root_password           => $root_password,
    package_name            => $package_name,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => deep_merge($default_override_options, $ssl_override_options),
  }

  # install mariadb-client alongside mariadb-server
  # otherwise mysql will try to install mysql-client
  if $package_name == 'mariadb-server' {
    class { '::mysql::client':
      package_name => 'mariadb-client',
    }
  }

  if ! empty($monitoring) {
    class { '::vision_mysql::server::monitoring::client':
      password => $monitoring['password'],
    }
  }

  if ! empty($backup) {
    class { '::vision_mysql::server::backup::client':
      password  => $backup['password'],
      databases => $backup['databases'],
    }
  }

  if $ldap {
    contain '::vision_mysql::server::ldap'
  }

}
