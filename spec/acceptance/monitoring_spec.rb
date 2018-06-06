require 'spec_helper_acceptance'

describe 'vision_mysql::server' do
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
end
