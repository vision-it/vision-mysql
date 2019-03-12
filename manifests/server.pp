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
      'plugin-load'              => 'auth_pam.so',
      'pam_use_cleartext_plugin' => true
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

  class { '::mysql::server':
    root_password           => $root_password,
    package_name            => $package_name,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => deep_merge($default_override_options, $ssl_override_options),
  }

  if ! empty($monitoring) {
    class { '::vision_mysql::server::monitoring':
      password => $monitoring['password'],
    }
  }

  if ! empty($backup) {
    class { '::vision_mysql::server::backup':
      password  => $backup['password'],
      databases => $backup['databases'],
    }
  }

}
