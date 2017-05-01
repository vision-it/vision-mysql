# creates a new mysql user
# grants that user all rights
# and exports that server to the phpmyadmin server instance
#
class vision_mysql::server::phpmyadmin::client (

  String $server,
  String $role,
  String $root_password = $::vision_mysql::server::root_password,

) {

  mysql_user { "root@${server}":
    ensure        => present,
    password_hash => mysql_password($root_password),
  }

  mysql_grant { "root@${server}/*.*":
    ensure     => present,
    options    => ['GRANT'],
    privileges => ['ALL'],
    user       => "root@${server}",
    table      => '*.*',
  }

  # create an entry for the phpmyadmin
  @@::phpmyadmin::servernode { "phpmyadmin-${::fqdn}":
    server_group  => 'dmz',
    myserver_name => $::fqdn,
    verbose_name  => $role,
  }

}
