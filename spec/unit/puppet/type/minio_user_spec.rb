# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/minio_user'

RSpec.describe 'the minio_user type' do
  it 'loads' do
    expect(Puppet::Type.type(:minio_user)).not_to be_nil
  end
end
