# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'vision_mysql::client' do
  context 'with cluster' do
    it 'idempotentlies run' do
      pp = <<-FILE
        class { 'vision_mysql::client':
        }
      FILE

      apply_manifest(pp, catch_failures: true)
    end
  end

  context 'packages installed' do
    describe package('mariadb-client') do
      it { is_expected.to be_installed }
    end
  end
end
