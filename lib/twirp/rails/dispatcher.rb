# frozen_string_literal: true

module Twirp
  module Rails
    class Dispatcher
      def initialize(service_class)
        # Check for a handler in the service's namespace, or in the root namespace
        # e.g. Twirp::Example::Cobbler::CobblerHandler or ::CobblerHandler
        @service_handler = if Object.const_defined?("#{service_class.module_parent}::#{service_class.service_name}Handler")
          "#{service_class.module_parent}::#{service_class.service_name}Handler".constantize
        else
          "#{service_class.service_name}Handler".constantize
        end
      end

      def respond_to_missing?(method, *)
        true
      end

      def method_missing(name, *args)
        request = args[0]
        env = args[1]
        @service_handler.new.process(name, request, env)
      end
    end
  end
end
