require 'spec_helper_acceptance'

describe 'vision_mysql::mariadb' do
  context 'with defaults and cluster' do
    it 'idempotentlies run' do
      pp = <<-FILE
        class { 'vision_mysql::mariadb':
              root_password => '123456',
              ldap => false,
              tls  => false,
              cluster => true,
              cluster_nodes => ['1.example.com', '2.example.com'],
              cluster_name => 'foo_bar_cluster',
              package_name => 'mariadb-server',
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

    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'MANAGED BY PUPPET' }
      its(:content) { is_expected.to match 'wsrep_on = ON' }
      its(:content) { is_expected.to match 'wsrep_provider = /usr/lib/galera/libgalera_smm.so' }
      its(:content) { is_expected.to match 'wsrep_cluster_name = foo_bar_cluster' }
      its(:content) { is_expected.to match 'wsrep_cluster_address = gcomm://1.example.com,2.example.com' }
      its(:content) { is_expected.to match 'wsrep_sst_method = rsync' }
      its(:content) { is_expected.to match 'wsrep_node_address' }
    end
  end

  describe command('mysql -e "select user,host from mysql.user"') do
    its(:exit_status) { is_expected.to eq 0 }
  end
end
