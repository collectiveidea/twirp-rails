# frozen_string_literal: true

require_relative "rails/version"

module Twirp
  module Rails
    class Error < StandardError; end
    # Your code goes here...
  end
end

require "rails/engine"
require "twirp"
require_relative "rails/callbacks"
require_relative "rails/configuration"
require_relative "rails/dispatcher"
require_relative "rails/handler"
require_relative "rails/rack/conditional_post"
require_relative "rails/routing"

# Require any _twirp.rb files in lib
# Dir.glob(Rails.root.join("lib", "*_twirp.rb")).each { |file| require file }

module Twirp
  class Service
    # Override initialize to make handler argument optional.
    # When left nil, we will use our dispatcher.
    alias_method :original_initialize, :initialize
    def initialize(handler = nil)
      handler ||= Twirp::Rails::Dispatcher.new(self.class)
      original_initialize(handler)
    end
  end

  module Rails
    class Engine < ::Rails::Engine
      engine_name "twirp"
      # endpoint MyRackApplication
      # # Add a load path for this specific Engine
      # config.autoload_paths << File.expand_path("lib/some/path", __dir__)

      initializer "twirp_rails_engine.add_middleware" do |app|
        app.middleware.insert_after ::Rack::ConditionalGet, Twirp::Rails::Rack::ConditionalPost

        ActionDispatch::Routing::Mapper.include Twirp::Rails::Routing::Helper
      end
    end

    class << self
      def configure
        @configuration ||= Configuration.new
        yield @configuration if block_given?
        @configuration
      end

      def services
        if @services.nil?
          @services = Twirp::Service.subclasses.map(&:new)

          # Install hooks that may be defined in the config
          @services.each do |service|
            @configuration.service_hooks.each do |hook_name, hook|
              service.send(hook_name, &hook)
            end
          end
        end

        @services
      end
    end
  end
end
