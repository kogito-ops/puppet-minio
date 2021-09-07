# frozen_string_literal: true

require 'spec_helper'

require 'puppet_x/minio/client'

RSpec.describe PuppetX::Minio::Client do
  before :each do
    described_class.instance_variable_set(:@client_location, nil)
  end

  describe 'execute' do
    context 'without client installed' do
      it 'raises an exception' do
        allow(File).to receive(:exist?).and_return(false)
        expect {
          described_class.execute('alias list')
        }.to raise_error(Puppet::ExecutionFailure)
      end
    end

    context 'with client installed' do
      before :each do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:readlink).and_return('/usr/local/sbin/minio-client')
        Puppet::Util::ExecutionStub.set do |command, _options|
          out = <<-JSONSTRINGS
          {"status":"success","alias":"test1"}
          {"status":"success","alias":"test2"}
          JSONSTRINGS

          out if command == '/usr/local/sbin/minio-client --json alias list'
        end
      end

      it 'parses result to array of json objects' do
        expect(described_class.execute('alias list')).to eq [
          {
            'status' => 'success',
            'alias' => 'test1',
          },
          {
            'status' => 'success',
            'alias' => 'test2',
          },
        ]
      end

      it 'only looks up for a client once' do
        expect(File).to receive(:exist?).once

        described_class.execute('alias list')
        described_class.execute('alias list')
      end

      it 'passes all provided options to execute' do
        Puppet::Util::ExecutionStub.set do |_command, options|
          expect(options[:test]).to eq true
          expect(options[:otherthing]).to eq 'test'
          expect(options[:failonfail]).to eq false

          ''
        end

        described_class.execute('alias list', test: true, otherthing: 'test', failonfail: false)
      end
    end
  end
end
