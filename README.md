# vision-mysql

[![Build Status](https://travis-ci.org/vision-it/vision-mysql.svg?branch=production)](https://travis-ci.org/vision-it/vision-mysql)

# Upgrading

Notes on upgrading MySQL Versions.

 - Create database backups.
 - Shutdown applications
 - Upgrade MySQL/Maria version.
 - Hint: The packages in the official MySQL repo are called `mysql-community-server`
 - Run `mysql_upgrade`

# Usage

```
contain vision_mysql
```

## With monitoring
```puppet
class {'::vision_mysql::server':
  root_password => 'foobar',
  monitoring    => {
    password => 'barfoo',
  }
}
```
This creates a mysql monitoring user.

## With backup

```puppet
class {'::vision_mysql::server':
  root_password => 'foobar',
  backup        => {
    databases => ['foo', 'bar'],
    password  => 'barfoo',
  }
}
```
