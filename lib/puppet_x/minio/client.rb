# frozen_string_literal: true

require 'json'

module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module Minio # rubocop:disable Style/ClassAndModuleChildren
    class Client # rubocop:disable Style/Documentation
      CLIENT_LINK_LOCATION = '/root/.minioclient'

      @client_location = nil

      def self.execute(args, **execute_args)
        ensure_client_installed
        cmd = "#{@client_location} --json #{args}"
        out = Puppet::Util::Execution.execute(cmd, failonfail: true, **execute_args)

        out.each_line.map do |line|
          JSON.parse(line)
        end
      end

      def self.ensure_client_installed
        return if @client_location

        unless installed?
          errormsg = [
            "Symlink to minio client does not exist at #{CLIENT_LINK_LOCATION}. ",
            'Make sure you installed the client before managing minio resources.',
          ]
          raise Puppet::ExecutionFailure, errormsg.join
        end

        @client_location = File.readlink(CLIENT_LINK_LOCATION)
      end

      def self.installed?
        File.exist?(CLIENT_LINK_LOCATION)
      end
    end
  end
end
