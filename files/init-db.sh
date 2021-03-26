#!/usr/bin/env bash
# This file is managed by Puppet

# Script to create a new Database and User to access it.
# The password is a random string that will be displayed via stdout

if [ $# -eq 0 ]
  then
      echo >&2 'Error: Please pass a database name:'
      echo >&2' > init-db.sh DATABASE_NAME'
      exit 1
fi

DATABASE_NAME=$1
USER_NAME=$1
PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

if [ -z "$PASSWORD" ]
  then
      echo >&2 '> Could not generate password'
      exit 1
fi

echo '> Creating Database and User'

mysql -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME; CREATE USER IF NOT EXISTS $USER_NAME@'%' IDENTIFIED BY '${PASSWORD}'; GRANT ALL PRIVILEGES ON $USER_NAME.* to $DATABASE_NAME@'%';"

if [ $? -ne 0 ]
  then
      echo >&2 '> Could not generate database and user'
      exit 1
fi

echo '> Password:'
echo $PASSWORD
