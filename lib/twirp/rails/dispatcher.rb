# frozen_string_literal: true
require "active_support/notifications"

module Twirp
  module Rails
    class Dispatcher
      def initialize(service_class)
        @service_handler = "#{service_class.service_name}Handler".constantize.new
      end

      def respond_to_missing?(method, *)
        true
      end

      def method_missing(name, *args)
        request = args[0]
        env = args[1]
        ActiveSupport::Notifications.instrument("endpoint_run.twirp_rails", endpoint: name, env: env) do
          @service_handler.process(name, request, env)
        end
      end
    end
  end
end
