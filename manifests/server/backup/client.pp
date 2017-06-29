# Configure regular database dumps
#
class vision_mysql::server::backup::client (

  String $password,
  Array $databases,

) {

  package { 'bzip2':
    ensure => present,
  }

  class { '::mysql::server::backup':
    backupuser        => 'backup',
    backuppassword    => $password,
    backupdir         => '/vision/db-backup/',
    backupdirmode     => '0700',
    backupdirowner    => root,
    backupdirgroup    => root,
    backupdatabases   => $databases,
    file_per_database => true,
    time              => ['19', '30'],
  }

  # Puppet Module only supports one Backup currently
  cron { 'MySQL-backup':
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => 'root',
    hour    => 12,
    minute  => 30,
  }

}
