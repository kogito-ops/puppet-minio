# frozen_string_literal: true

require 'spec_helper'

describe 'minio', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to contain_class('minio') }
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_anchor('minio::begin') }
        it { is_expected.to contain_anchor('minio::end') }
        it { is_expected.to contain_class('minio::user') }
        it { is_expected.to contain_class('minio::install').that_comes_before('Class[minio::config]') }
        it { is_expected.to contain_class('minio::config').that_notifies('Class[minio::service]') }
        it { is_expected.to contain_class('minio::service') }
      end
    end
  end
end
