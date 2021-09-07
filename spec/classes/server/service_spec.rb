# frozen_string_literal: true

require 'spec_helper'

describe 'minio::server::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        let :params do
          {
            manage_service: true,
            service_provider: 'systemd',
            service_ensure: 'running',
          }
        end

        it { is_expected.to contain_service('minio') }
      end
    end
  end
end
