# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/minio_client_alias'

RSpec.describe 'the minio_client_alias type' do
  it 'loads' do
    expect(Puppet::Type.type(:minio_client_alias)).not_to be_nil
  end
end
