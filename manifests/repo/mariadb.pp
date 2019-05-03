# Class: vision_mysql::repo::mariadb
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_mysql::repo::mariadb
#

class vision_mysql::repo::mariadb (

  $version = '10.3',

) {

  contain apt

  $location = "http://downloads.mariadb.com/MariaDB/mariadb-${version}/repo/debian/"
  $repo = 'main'
  $key_id = '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB'
  $key_server = 'hkp://keyserver.ubuntu.com:80'

  apt::source { 'mariadb':
    location => $location,
    release  => $::lsbdistcodename,
    repos    => $repo,
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
