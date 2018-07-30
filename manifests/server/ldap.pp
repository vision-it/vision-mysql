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
      'libnss-ldapd',
      'libpam-ldap',
      'ldap-utils',
    ]:
      ensure => present
  }

  file { '/etc/nsswitch.conf':
    ensure  => present,
    content => template('vision_mysql/nsswitch.conf'),
  }

  if ($facts['os']['name'] == 'Debian') and ($facts['os']['release']['major'] == '8') {
    $pam_conf = '/etc/pam_ldap.conf'
  }
  else {
    $pam_conf = '/etc/libnss-ldap.conf'
  }

  file { 'LDAP PAM config':
    ensure  => present,
    path    => $pam_conf,
    content => template('vision_mysql/pam_ldap.conf.erb'),
  }

  file { '/etc/pam.d/mariadb':
    ensure  => present,
    content => template('vision_mysql/pam-mariadb'),
  }

  mysql::plugin { 'auth_pam':
    ensure => present,
    soname => 'auth_pam.so',
  }

}
