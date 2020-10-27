# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'vision_mysql::server with tls' do
  context 'with TLS' do
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
        }
      FILE

      apply_manifest(pp, catch_failures: false)
      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'files provisioned' do
    describe file('/root/.my.cnf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end

    describe file('/etc/mysql/ca-cert.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'mysql' }
      its(:content) { is_expected.to match 'CERTIFICATE' }
    end

    describe file('/etc/mysql/cert.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'mysql' }
      its(:content) { is_expected.to match 'CERTIFICATE' }
    end

    describe file('/etc/mysql/key.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
      it { is_expected.to be_owned_by 'mysql' }
      its(:content) { is_expected.to match 'PRIVATE KEY' }
    end

    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(/^ssl$/) }
      its(:content) { is_expected.to match(/^ssl-ca =/) }
      its(:content) { is_expected.to match(/^ssl-cert =/) }
      its(:content) { is_expected.to match(/^ssl-key =/) }
    end
  end

  describe command('mysql -e "select user,host from mysql.user"') do
    its(:exit_status) { is_expected.to eq 0 }
  end
end
