require 'spec_helper_acceptance'

describe 'vision_mysql::server' do
  context 'with TLS' do
    it 'idempotentlies run' do
      pp = <<-FILE
        class { 'vision_mysql::server':
              tls => true,
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

    describe file('/etc/mysql/ca-cert.pem') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'CERTIFICATE' }
    end

    describe file('/etc/mysql/server-cert.pem') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'CERTIFICATE' }
    end

    describe file('/etc/mysql/server-key.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
      its(:content) { is_expected.to match 'PRIVATE KEY' }
    end

    describe file('/etc/mysql/my.cnf') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match /^ssl$/ }
      its(:content) { is_expected.to match /^ssl-ca =/ }
      its(:content) { is_expected.to match /^ssl-cert =/ }
      its(:content) { is_expected.to match /^ssl-key =/ }
    end

  end

  describe command('mysql -e "select user,host from mysql.user"') do
    its(:exit_status) { is_expected.to eq 0 }
  end
end
