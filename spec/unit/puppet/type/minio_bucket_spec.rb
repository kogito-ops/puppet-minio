# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/minio_bucket'

RSpec.describe 'the minio_bucket type' do
  it 'loads' do
    expect(Puppet::Type.type(:minio_bucket)).not_to be_nil
  end
end
