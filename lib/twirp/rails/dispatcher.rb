# frozen_string_literal: true

module Twirp
  module Rails
    class Dispatcher
      def initialize(service_class)
        @service_handler = "#{service_class.service_name}Handler".constantize
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
