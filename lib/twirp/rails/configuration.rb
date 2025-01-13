# frozen_string_literal: true

module Twirp
  module Rails
    class Configuration
      # Whether to automatically mount routes at endpoint. Defaults to false
      attr_accessor :auto_mount

      # Where to mount twirp routes. Defaults to /twirp
      attr_accessor :endpoint

      # Logger to use for Twirp requests. Defaults to Rails.logger
      attr_accessor :logger

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
        @endpoint = "/twirp"
        @load_paths = ["lib"]
        @logger = Logger
        @middleware = []
        @service_hooks = {}
      end
    end
  end
end
