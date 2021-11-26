module PuppetX
  module Minio
    module Util
      def unwrap_maybe_sensitive(param)
        if param.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
          return param.unwrap
        end

        param
      end
    end
  end
end
