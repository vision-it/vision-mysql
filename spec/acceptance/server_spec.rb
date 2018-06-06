require 'spec_helper_acceptance'

describe 'vision_mysql::server' do
  context 'with defaults' do
    it 'idempotentlies run' do
      pp = <<-FILE
        class { 'vision_mysql::server':
          root_password => 'foobar',
        }
      FILE

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'files provisioned' do
    describe file('/root/.my.cnf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end
  end

    describe command('mysql -e "select user,host from mysql.user"') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
  context 'with monitoring' do
    it 'creates monitoring user' do
      pp = <<-FILE
        $monitoring = {
          password => barfoo,
        }
        class { 'vision_mysql::server':
          monitoring    => $monitoring,
          root_password => 'foobar',
        }
      FILE

      apply_manifest(pp, catch_failures: true)
    end

    describe command('mysql -e "select user from mysql.user"') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match 'monitoring' }
    end
  end

  context 'with backup' do
    it 'creates backups' do
      pp = <<-FILE
        file { '/vision':
          ensure => directory,
        }
        $backup = {
          password  => 'barfoo',
          databases => ['foo', 'bar'],
        }
        class { 'vision_mysql::server':
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
