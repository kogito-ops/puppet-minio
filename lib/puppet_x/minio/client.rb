# frozen_string_literal: true

require 'json'

module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module Minio # rubocop:disable Style/ClassAndModuleChildren
    class Client # rubocop:disable Style/Documentation
      CLIENT_LOCATION = '/root/.minioclient'.freeze

      class_variable_set(:@@client_ensured, false)

      def self.execute(args, **execute_args)
        ensure_client_installed
        cmd = "#{CLIENT_LOCATION} --json #{args}"
        out = Puppet::Util::Execution.execute(cmd, failonfail: true, **execute_args)

        out.each_line.map do |line|
          JSON.parse(line)
        end
      end

      def self.ensure_client_installed
        return if class_variable_get(:@@client_ensured)

        unless installed?
          errormsg = [
            "Symlink to minio client does not exist at #{CLIENT_LOCATION}. ",
            'Make sure you installed the client before managing minio resources.',
          ]
          raise Puppet::ExecutionFailure, errormsg.join
        end

        class_variable_set(:@@client, true)
      end

      def self.installed?
        File.exist?(CLIENT_LOCATION)
      end
    end
  end
end
