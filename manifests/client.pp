# Class: vision_mysql::client
# ===========================
#
# Manage MariaDB Client Installation
#
# Parameters
# ----------
#
# @param package_name SQL client package name
#
# Examples
# --------
#
# @example
# contain ::vision_mysql::client
#

class vision_mysql::client (

  String $package_name = 'mariadb-client',

) {

  class { '::mysql::client':
    package_name => $package_name,
  }

}
