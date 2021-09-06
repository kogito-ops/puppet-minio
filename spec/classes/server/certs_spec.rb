# frozen_string_literal: true

require 'spec_helper'

describe 'minio::server::certs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          cert_ensure: 'present',
          owner: 'minio',
          group: 'minio',
          cert_directory: '/etc/minio/certs',
          default_cert_name: 'miniodefault',
          default_cert_configuration: {},
          additional_certs: {},
        }
      end
      let(:pre_condition) do
        <<-MANIFEST
        class { 'certs': service => false, validate_x509 => false }
        MANIFEST
      end

      it {
        is_expected.to compile
        is_expected.not_to contain_certs__site('miniodefault')
        is_expected.not_to contain_file('/etc/minio/certs/private.key')
        is_expected.not_to contain_file('/etc/minio/certs/public.crt')
      }

      context 'with default cert' do
        let(:params) do
          super().merge(default_cert_configuration: {
                          source_path: 'puppet:///modules/minio/examples',
                          source_cert_name: 'localhost',
                          source_key_name: 'localhost',
                        })
        end

        it {
          is_expected.to compile
          is_expected.to contain_certs__site('miniodefault')
          is_expected.to contain_file('/etc/minio/certs/private.key')
            .with(ensure: 'link', target: '/etc/minio/certs/miniodefault.key')
            .that_requires('Certs::Site[miniodefault]')
          is_expected.to contain_file('/etc/minio/certs/public.crt')
            .with(ensure: 'link', target: '/etc/minio/certs/miniodefault.pem')
            .that_requires('File[/etc/minio/certs/private.key]')
        }
      end

      context 'with additional certs' do
        let(:params) do
          super().merge(additional_certs: {
                          example: {
                            source_path: 'puppet:///modules/minio/examples',
                            source_cert_name: 'example.test',
                            source_key_name: 'example.test',
                          },
                        })
        end

        it {
          is_expected.to compile
          is_expected.to contain_certs__site('example')
          is_expected.to contain_file('/etc/minio/certs/example/private.key').with(ensure: 'link', target: '/etc/minio/certs/example/example.key')
          is_expected.to contain_file('/etc/minio/certs/example/public.crt').with(ensure: 'link', target: '/etc/minio/certs/example/example.pem')

          is_expected.to contain_file('/etc/minio/certs/example/private.key').that_requires('Certs::Site[example]')
          is_expected.to contain_file('/etc/minio/certs/example/public.crt').that_requires('File[/etc/minio/certs/example/private.key]')
        }
      end
    end
  end
end
