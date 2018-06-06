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
