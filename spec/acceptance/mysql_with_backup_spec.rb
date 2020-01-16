require 'spec_helper_acceptance'

describe 'vision_mysql::server' do
  context 'with backup' do
    it 'creates backups' do
      setup = <<-FILE
        user { 'nagios':
          ensure => present,
        }
        file { '/vision':
          ensure => directory,
        }
        # Manually start with init, since we aint got so systemd
        if($facts[os][distro][codename] == 'stretch') {
         $p = 'mysql-server'
        } else {
         $p = 'mariadb-server'
        }
        package { $p:
          ensure => present,
        }->
          exec { '/bin/cp -p /etc/init.d/mysql /etc/init.d/mariadb':
        }->
          exec { '/bin/bash /etc/init.d/mysql start':
        }
      FILE
      apply_manifest(setup, accept_all_exit_codes: true, catch_failures: false)

      pp = <<-FILE
        $backup = {
          password  => 'barfoo',
          databases => ['foo', 'bar'],
        }

        # mysql no longer in buster
        if($facts[os][distro][codename] == 'stretch') {
         $p = 'mysql-server'
        } else {
         $p = 'mariadb-server'
        }

        class { 'vision_mysql::server':
          package_name  => $p,
          backup        => $backup,
          root_password => 'foobar',
        }
      FILE
      apply_manifest(pp, catch_failures: true)
    end

    describe command('mysql -e "select user from mysql.user"') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match 'backup' }
    end

    describe file('/usr/local/sbin/mysqlbackup.sh') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 700 }
      its(:content) { is_expected.to match 'barfoo' }
      its(:content) { is_expected.to match 'max_allowed_packet' }
      its(:content) { is_expected.to match 'foo.*sql.bz2' }
      its(:content) { is_expected.to match 'bar.*sql.bz2' }
    end
    describe cron do
      it { is_expected.to have_entry '30 19 * * * /usr/local/sbin/mysqlbackup.sh' }
      it { is_expected.to have_entry '30 12 * * * /usr/local/sbin/mysqlbackup.sh' }
    end
    describe package('bzip2') do
      it { is_expected.to be_installed }
    end
  end
end
