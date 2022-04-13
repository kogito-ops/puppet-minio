# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/minio_group'

RSpec.describe 'the minio_group type' do
  it 'loads' do
    expect(Puppet::Type.type(:minio_group)).not_to be_nil
  end
end
