# TLS Configuration
#
class vision_mysql::config::tls (

  String $cert,
  String $key,
  String $ca_cert,

) {

  file { '/etc/mysql/ca-cert.pem':
    ensure  => present,
    owner   => 'mysql',
    mode    => '0640',
    content => $ca_cert,
  }

  file { '/etc/mysql/key.pem':
    ensure  => present,
    owner   => 'mysql',
    mode    => '0600',
    content => $key,
  }

  file { '/etc/mysql/cert.pem':
    ensure  => present,
    owner   => 'mysql',
    mode    => '0640',
    content => $cert,
  }

}
