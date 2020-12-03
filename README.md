# vision-mysql

[![Build Status](https://travis-ci.com/vision-it/vision-mysql.svg?branch=production)](https://travis-ci.com/vision-it/vision-mysql)

## Upgrading MySQL Major Versions

Notes on upgrading MySQL Versions.

 - Create database backups.
 - Shutdown applications
 - Upgrade MySQL/Maria version.
 - Hint: The packages in the official MySQL repo are called `mysql-community-server`
 - Run `mysql_upgrade`

## Bootrapping Galera

The initial Cluster node needs to run *galera_new_cluster* and have the mariadbuser.

```
# Bootstrap User
$server1: apt install mariadb-server mariadb-backup
$server1: mysql -e "CREATE USER 'mariabackup'@%' IDENTIFIED BY 'mypassword';"
$server1: mysql -e "GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@%';"
$server1: systemctl stop mariadb

# Galera Config via Puppet
puppet apply site.pp
systemctl stop mariadb

# Bootstrap Cluster
galera_new_cluster
```
