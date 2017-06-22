#
class vision_mysql::server::backup::client (
  String $password,
  Array $databases,
) {

  # debian package name for bzcat util
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
    time              => ['12,19', '15'],
  }
}
