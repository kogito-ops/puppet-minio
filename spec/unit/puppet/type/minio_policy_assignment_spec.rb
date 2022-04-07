# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/minio_policy_assignment'

RSpec.describe 'the minio_policy_assignment type' do
  it 'loads' do
    expect(Puppet::Type.type(:minio_policy_assignment)).not_to be_nil
  end
end
