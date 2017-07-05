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

  Hash $monitoring = {},
  Hash $backup     = {},
  Hash $phpmyadmin = {},

  Optional[String] $phpmyadminserver = undef,

) {
  class { '::mysql::server':
    root_password           => $root_password,
    package_name            => $package_name,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => {
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
      }
    }
      }

  # install mariadb-client alongside mariadb-server
  # otherwise mysql will try to install mysql-client
  if $package_name == 'mariadb-server' {
    class { '::mysql::client':
      package_name => 'mariadb-client',
    }
  }

  if $phpmyadminserver {
    class { '::vision_mysql::server::phpmyadmin::client':
      server => $phpmyadmin['server'],
      role   => $phpmyadmin['role'],
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
}
