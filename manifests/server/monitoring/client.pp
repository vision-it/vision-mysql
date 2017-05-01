#
class vision_mysql::server::monitoring::client(
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
}
