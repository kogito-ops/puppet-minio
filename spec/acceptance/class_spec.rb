# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'with default parameters ', if: ['debian', 'redhat', 'ubuntu'].include?(os[:family]) do
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
