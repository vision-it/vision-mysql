# Class: vision_mysql::server
# ===========================
#
# Manage MySQL Installation
#
# Parameters
# ----------
#
# @param root_password MySQL Root Password
# @param package_name Apt package name
# @param monitoring List of Monitoring Users
# @param backup List of Backup Config
# @param ldap = Enable LDAP configuration (bool)
# @param tls  = Enable TLS configuration (bool)
# @param manage_repo = Use MySQL Apt repository
# @param server_cert = TLS Certificate
# @param server_key = TLS Private Key
# @param ca_cert = TLS CA Certificate
#
# Examples
# --------
#
# @example
# contain ::vision_mysql::server
#

class vision_mysql::server (

  String $root_password,
  String $package_name = 'mysql-server',
  Hash   $monitoring   = {},
  Hash   $backup       = {},
  Boolean $ldap = false,
  Boolean $tls  = false,
  Boolean $manage_repo = false,
  Optional[String] $server_cert = undef,
  Optional[String] $server_key = undef,
  Optional[String] $ca_cert = undef,

) {

  if $manage_repo {
    contain vision_mysql::repo::mysql
  }

  $default_override_options = {
    'client' => {
      'default-character-set' => 'utf8',
    },
    'mysql'  => {
      'default-character-set' => 'utf8',
    },
    'mysqld' => {
      'sql-mode'             => 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION',
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

  file { '/etc/logrotate.d/mysql-server':
    ensure  => present,
    content => template('vision_mysql/mysql-server.logrotate'),
    require => Class['::mysql::server'],
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
