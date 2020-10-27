# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'vision_mysql::server with galera' do
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
              cluster_nodes => ['1.example.com', '2.example.com'],
              cluster_name => 'foo_bar_cluster',
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

    describe package('mariadb-backup') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'MANAGED BY PUPPET' }
      its(:content) { is_expected.to match 'wsrep_on = ON' }
      its(:content) { is_expected.to match 'wsrep_provider = /usr/lib/galera/libgalera_smm.so' }
      its(:content) { is_expected.to match 'wsrep_cluster_name = foo_bar_cluster' }
      its(:content) { is_expected.to match 'wsrep_cluster_address = gcomm://1.example.com,2.example.com' }
      its(:content) { is_expected.to match 'wsrep_sst_method = mariabackup' }
      its(:content) { is_expected.to match 'wsrep_node_address' }
      its(:content) { is_expected.to match 'bind-address = 0.0.0.0' }
    end
  end
end
