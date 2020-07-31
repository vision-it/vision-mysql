# Class: vision_mysql::client
# ===========================

# Manage MariaDB Client Installation

class vision_mysql::client (

  String $package_name = 'mariadb-client',

) {

  class { '::mysql::client':
    package_name => $package_name,
  }

}
