# frozen_string_literal: true

require 'spec_helper'

describe 'minio::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          manage_client_installation: true,
          package_ensure: 'present',
          base_url: 'https://dl.minio.io/client/mc/release',
          version: 'RELEASE.2021-07-27T06-46-19Z',
          checksum: '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
          checksum_type: 'sha256',
          installation_directory: '/opt/minioclient',
          binary_name: 'minio-client',
          aliases: {},
          purge_unmanaged_aliases: false,
        }
      end

      context 'with all defaults' do
        it {
          is_expected.to contain_class('minio::client::install')
          is_expected.to contain_class('minio::client::config').that_requires('Class[minio::client::install]')
        }
      end

      context 'with unmanaged client installation' do
        let(:params) do
          super().merge(manage_client_installation: false)
        end

        it {
          is_expected.to compile.with_all_deps
          is_expected.to have_resource_count(0)
          is_expected.to have_class_count(1) # Should only contain minio::client itself
        }
      end
    end
  end
end
