# vision-mysql

[![Build Status](https://travis-ci.org/vision-it/vision-mysql.svg?branch=production)](https://travis-ci.org/vision-it/vision-mysql)

This is a puppet profile.


## Installation

Include in the *Puppetfile*:

```
mod vision_mysql:
    :git => 'https://github.com/vision-it/vision-mysql.git,
    :ref => 'production'
```

## Parameters
### Server
##### String `vision_mysql::server::root_password`
No default.

#### Backup
##### Hash `vision_mysql::server::backup`
No default. Hash to configure the backup options. Available options are:
* String `password`
* Array `databases`

#### Monitoring
##### Hash `vision_mysql::server::monitoring`
No default. Hash to configure the monitoring options. Available options are:
* String `password`

#### Phpmyadmin
##### Hash `vision_mysql::server::phpmyadmin`
No default. Hash to configure the monitoring options. Available options are:
* String `server`
* String `role`
  Verbose name of the node in the phpmyadmin interface.

### Client

## Usage

All three use cases can be combined.

### With monitoring
```puppet
class {'::vision_mysql::server':
  root_password => 'foobar',
  monitoring    => {
    password => 'barfoo',
  }
}
```
This creates a mysql monitoring user.

### With backup
```puppet
class {'::vision_mysql::server':
  root_password => 'foobar',
  backup        => {
    databases => ['foo', 'bar'],
    password  => 'barfoo',
  }
}
```
See the backup [Manifest](manifests/server/backup/client.pp) for further
information.


### With phpmyadmin export
```puppet
class {'::vision_mysql::server':
  root_password => 'foobar',
  phpmyadmin    => {
    server => 'full.qualified.domain.name.of.phpmadmin.server',
    role   => 'Node description',
  }
}
```

This creates a local mysql user accounts with connection privileges from the
`phpmyadmin` server instance. The remote server collects the local servernode
via exported resources.

