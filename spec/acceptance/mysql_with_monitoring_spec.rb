require 'spec_helper_acceptance'

describe 'vision_mysql::server' do
  context 'with monitoring' do
    it 'creates monitoring user' do
      pp = <<-FILE
        # mysql no longer in buster
        if($facts[os][distro][codename] == 'stretch') {
         $p = 'mysql-server'
        } else {
         $p = 'mariadb-server'
        }

        $monitoring = {
          password => barfoo,
        }
        class { 'vision_mysql::server':
          package_name  => $p,
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
