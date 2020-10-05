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
end
