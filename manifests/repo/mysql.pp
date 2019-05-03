# Class: vision_mysql::repo::mysql
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_mysql::repo::mysql
#

class vision_mysql::repo::mysql (

  $version = 'mysql-5.7',

) {

  contain apt

  $location = 'http://repo.mysql.com/apt/debian/'
  $key_id = 'A4A9406876FCBD3C456770C88C718D3B5072E1F5'
  $key_server = 'hkp://pgp.mit.edu'

  apt::source { 'mysql':
    location => $location,
    release  => $::lsbdistcodename,
    repos    => $version,
    key      => {
      id     => $key_id,
      server => $key_server,
    },
    include  => {
      src => false,
      deb => true,
    },
  }


}
