# Add monitoring user
#
class vision_mysql::server::monitoring (

  String $password,

) {

  mysql_user { 'monitoring@localhost':
    ensure        => present,
    password_hash => mysql_password($password),
  }

  mysql_grant { 'monitoring@localhost/*.*':
    ensure     => present,
    privileges => ['USAGE'],
    user       => 'monitoring@localhost',
    table      => '*.*',
  }

  file { '/etc/mysql/monitoring.cnf':
    ensure  => present,
    owner   => 'nagios',
    mode    => '0600',
    content => template('vision_mysql/monitoring.cnf.erb'),
  }
}
