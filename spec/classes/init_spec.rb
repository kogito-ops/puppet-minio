# frozen_string_literal: true

require 'spec_helper'

describe 'minio', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it {
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('minio::server')
        }
      end
    end
  end
end
