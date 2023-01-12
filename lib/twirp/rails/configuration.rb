# frozen_string_literal: true

module Twirp
  module Rails
    class Configuration
      # A lambda that accepts |rack_env, env| and is passed to Twirp::Service
      # See: https://github.com/twitchtv/twirp-ruby/wiki/Service-Hooks
      # for available hooks
      attr_accessor :service_hooks

      def initialize
        @service_hooks = {}
      end
    end
  end
end
