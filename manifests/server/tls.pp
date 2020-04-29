# TLS Configuration
#
class vision_mysql::server::tls (

  String $server_cert,
  String $server_key,
  String $ca_cert,

) {

  file { '/etc/mysql/ca-cert.pem':
    ensure  => present,
    owner   => 'mysql',
    content => $ca_cert,
  }

  file { '/etc/mysql/server-key.pem':
    ensure  => present,
    owner   => 'mysql',
    mode    => '0600',
    content => $server_key,
  }

  file { '/etc/mysql/server-cert.pem':
    ensure  => present,
    owner   => 'mysql',
    content => $server_cert,
  }

}
