# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'minio', if: ['debian', 'redhat', 'ubuntu'].include?(os[:family]) do
  describe 'with default parameters ' do
    pp = <<-PUPPETCODE
      class { 'minio': }
    PUPPETCODE

    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    describe group('minio') do
      it { is_expected.to exist }
    end

    describe user('minio') do
      it { is_expected.to exist }
    end

    describe file('/opt/minio') do
      it { is_expected.to be_directory }
    end

    describe file('/etc/minio') do
      it { is_expected.to be_directory }
    end

    describe file('/etc/minio/config') do
      it { is_expected.to be_file }
    end

    describe file('/opt/minio/minio') do
      it { is_expected.to be_file }
    end

    describe file('/var/minio') do
      it { is_expected.to be_directory }
    end

    describe service('minio') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running.under('systemd') }
    end

    describe process('minio') do
      its(:user) { is_expected.to eq 'minio' }
      its(:args) { is_expected.to match 'server --certs-dir /etc/minio/certs --address 127.0.0.1:9000 /var/minio' }
    end

    describe port(9000) do
      it { is_expected.to be_listening }
    end

    describe file('/usr/local/bin/minio-client') do
      it {
        is_expected.to be_file
        is_expected.to be_mode 755
        is_expected.to be_owned_by 'root'
        is_expected.to be_grouped_into 'root'
      }
    end

    describe file('/root/.minioclient') do
      it {
        is_expected.to be_symlink
        is_expected.to be_linked_to '/usr/local/bin/minio-client'
        is_expected.to be_owned_by 'root'
        is_expected.to be_grouped_into 'root'
      }
    end
  end

  describe 'with multiple storage roots', if: ['debian', 'redhat', 'ubuntu'].include?(os[:family]) do
    pp = <<-PUPPETCODE
      class { 'minio':
        storage_root  => [
          '/var/minio1',
          '/var/minio2',
          '/var/minio3',
          '/var/minio4',
        ],
        configuration => {
          'MINIO_DEPLOYMENT_DEFINITION' => '/var/minio{1...4}',
        },
      }
    PUPPETCODE

    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    describe file('/var/minio1') do
      it { is_expected.to be_directory }
    end

    describe file('/var/minio2') do
      it { is_expected.to be_directory }
    end

    describe file('/var/minio3') do
      it { is_expected.to be_directory }
    end

    describe file('/var/minio4') do
      it { is_expected.to be_directory }
    end

    describe service('minio') do
      it {
        is_expected.to be_enabled
        is_expected.to be_running.under('systemd')
      }
    end

    describe process('minio') do
      its(:user) { is_expected.to eq 'minio' }
      its(:args) { is_expected.to match 'server --certs-dir /etc/minio/certs --address 127.0.0.1:9000 /var/minio{1...4}' }
    end
  end

  describe 'with extra commandline options', if: ['debian', 'redhat', 'ubuntu'].include?(os[:family]) do
    pp = <<-PUPPETCODE
      class { 'minio':
        configuration => {
          'MINIO_OPTS' => '"--quiet --anonymous"',
        },
      }
    PUPPETCODE

    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    describe service('minio') do
      it {
        is_expected.to be_enabled
        is_expected.to be_running.under('systemd')
      }
    end

    describe process('minio') do
      its(:user) { is_expected.to eq 'minio' }
      its(:args) { is_expected.to match 'server --quiet --anonymous --certs-dir /etc/minio/certs --address 127.0.0.1:9000 /var/minio' }
    end
  end
end
