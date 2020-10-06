require 'spec_helper_acceptance'

describe 'vision_mysql::server' do
  context 'with cluster' do
    it 'idempotentlies run' do
      setup = <<-FILE
        package { 'mariadb-server':
          ensure => present,
        }->
          exec { '/bin/cp -p /etc/init.d/mysql /etc/init.d/mariadb':
        }->
          exec { '/bin/bash /etc/init.d/mysql start':
        }
      FILE
      apply_manifest(setup, accept_all_exit_codes: true, catch_failures: false)

      pp = <<-FILE
        class { 'vision_mysql::server':
              service_manage => false,
              service_enabled => false,
        }
      FILE

      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'files provisioned' do
    describe file('/root/.my.cnf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end

    describe file('/root/init-db.sh') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 740 }
    end

    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'MANAGED BY PUPPET' }
      its(:content) { is_expected.to match 'bind-address = 0.0.0.0' }
    end
  end
end
