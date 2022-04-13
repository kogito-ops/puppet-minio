# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/minio_policy'

RSpec.describe 'the minio_policy type' do
  it 'loads' do
    expect(Puppet::Type.type(:minio_policy)).not_to be_nil
  end
end
