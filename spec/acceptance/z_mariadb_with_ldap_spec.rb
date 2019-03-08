require 'spec_helper_acceptance'

describe 'vision_mysql::mariadb' do
  context 'with ldap' do
    it 'idempotentlies run' do
      pp = <<-FILE
        class { 'vision_mysql::server':
              package_name => 'mariadb-server',
              ldap => true,
              tls  => false,
        }
      FILE

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'files provisioned' do
    describe package('libpam-ldap') do
      it { is_expected.to be_installed }
    end

    describe file('/root/.my.cnf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end

    describe file('/etc/nsswitch.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'ldap' }
    end

    describe file('/etc/pam_ldap.conf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'base dc=foobase' }
      its(:content) { is_expected.to match 'ldap_version 3' }
    end

    describe file('/etc/pam.d/mariadb') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'auth required pam_ldap.so' }
      its(:content) { is_expected.to match 'account required pam_ldap.so' }
    end

    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match /^ssl = false/ }
    end
  end

  describe command('mysql -e "select user,host from mysql.user"') do
    its(:exit_status) { is_expected.to eq 0 }
  end
end
