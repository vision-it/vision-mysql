# Class: vision_mysql
# ===========================

class vision_mysql::server::ldap (

  String $ldap_uri,
  String $bind_dn,
  String $bind_password,
  String $base_dn,

) {

  contain '::mysql::server'

  package {
    [
      'libnss-ldap',
      'libpam-ldap',
      'ldap-utils',
    ]:
      ensure => present
  }

  file { '/etc/nsswitch.conf':
    ensure  => present,
    content => template('vision_mysql/nsswitch.conf'),
  }

  file { '/etc/pam_ldap.conf':
    ensure  => present,
    path    => $pam_conf,
    content => template('vision_mysql/pam_ldap.conf.erb'),
  }

  file { '/etc/libnss-ldap.conf':
    ensure  => present,
    path    => $pam_conf,
    content => template('vision_mysql/pam_ldap.conf.erb'),
  }

  file { '/etc/pam.d/mariadb':
    ensure  => present,
    content => template('vision_mysql/pam-mariadb'),
  }

}
