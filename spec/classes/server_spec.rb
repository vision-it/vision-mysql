# frozen_string_literal: true

require 'spec_helper'
require 'hiera'

describe 'vision_mysql::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(root_home: '/root')
      end

      context 'compile' do
        it { is_expected.to compile.with_all_deps }
      end

      context 'with tls' do
        let(:params) do
          {
            key: 'SECRET'
          }
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('vision_mysql::config::tls') }
      end
    end
  end
end
