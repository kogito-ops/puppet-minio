# frozen_string_literal: true

require 'spec_helper'

describe 'minio::server::user' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with all defaults' do
        let :params do
          {
            manage_user: true,
            manage_group: true,
            manage_home: true,
            owner: 'minio',
            group: 'minio',
            home: '/home/minio',
          }
        end

        it { is_expected.to contain_group('minio') }
        it { is_expected.to contain_user('minio') }
      end
    end
  end
end
