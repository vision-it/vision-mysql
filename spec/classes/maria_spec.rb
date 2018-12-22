require 'spec_helper'
require 'hiera'

describe 'vision_mysql::mariadb' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      context 'compile' do
        it { is_expected.to compile.with_all_deps }
      end

      context 'without backup' do
        let(:params) do
          {
            backup: {}
          }
        end

        it { is_expected.not_to contain_class('vision_mysql::server::backup::client') }
      end

      context 'with ldap' do
        let(:params) do
          {
            ldap: true
          }
        end
        it { is_expected.to contain_class('vision_mysql::server::ldap') }
      end

      context 'with tls' do
        let(:params) do
          {
            tls: true
          }
        end
        it { is_expected.to compile }
      end
    end
  end
end
