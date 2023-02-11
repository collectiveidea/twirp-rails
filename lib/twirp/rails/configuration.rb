# frozen_string_literal: true

module Twirp
  module Rails
    class Configuration
      # Whether to automatically mount routes at /twirp
      attr_accessor :auto_mount

      # An array of directories to search for *_twirp.rb files
      # Defaults to ["lib"]
      attr_accessor :load_paths

      # An array of Rack middleware to use
      attr_accessor :middleware

      # A hash of lambdas that accepts |rack_env, env| and is passed to Twirp::Service
      # See: https://github.com/twitchtv/twirp-ruby/wiki/Service-Hooks
      # for available hooks
      attr_accessor :service_hooks

      def initialize
        @auto_mount = false
        @load_paths = ["lib"]
        @middleware = []
        @service_hooks = {}
      end
    end
  end
end
