require 'spec_helper_acceptance'

describe 'minio class' do
  context 'with default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-PUPPET
      class { 'minio': }
      PUPPET

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
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

    describe file('/etc/minio/config.json') do
      it { is_expected.to be_file }
    end

    describe file('/var/log/minio') do
      it { is_expected.to be_directory }
    end

    describe file('/opt/minio/minio') do
      it { is_expected.to be_file }
    end

    describe file('/var/minio') do
      it { is_expected.to be_directory }
    end

    describe file('/lib/systemd/system/minio.service') do
      it { is_expected.to be_file }
    end

    describe port(9000) do
      it { is_expected.to be_listening }
    end
  end
end
