require 'spec_helper'
require 'hiera'

describe 'vision_mysql::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      context 'compile' do
        it { is_expected.to compile }
      end

      context 'without phpmyadmin' do
        it { is_expected.not_to contain_class('vision_mysql::server::phpmyadmin::client') }
      end

      context 'with phpmyadmin' do
        let(:params) do
          {
            phpmyadminserver: 'localhost'
          }
        end

        it { is_expected.to contain_class('vision_mysql::server::phpmyadmin::client') }
      end

      context 'without monitoring' do
        let(:params) do
          {
            monitoring: {}
          }
        end

        it { is_expected.not_to contain_class('vision_mysql::server::monitoring::client') }
      end

      context 'without backup' do
        let(:params) do
          {
            backup: {}
          }
        end

        it { is_expected.not_to contain_class('vision_mysql::server::backup::client') }
      end
    end
  end
end
