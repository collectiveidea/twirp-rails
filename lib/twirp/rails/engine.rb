# frozen_string_literal: true

require "rails/engine"
require "rack/etag"
require_relative "rack/conditional_post"

module Twirp
  module Rails
    class Engine < ::Rails::Engine
      engine_name "twirp"
      # endpoint MyRackApplication
      # # Add a load path for this specific Engine
      # config.autoload_paths << File.expand_path("lib/some/path", __dir__)
      middleware.use Twirp::Rails::Rack::ConditionalPost
      middleware.use ::Rack::ETag
    end

    class << self
      def configure
        yield configuration if block_given?
        configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def services
        if @services.nil?
          configuration.load_paths.each do |directory|
            Dir.glob(::Rails.root.join(directory, "*_twirp.rb")).sort.each { |file| require file }
          end

          @services = Twirp::Service.subclasses.map(&:new)

          # Install hooks that may be defined in the config
          @services.each do |service|
            configuration.service_hooks.each do |hook_name, hook|
              service.send(hook_name, &hook)
            end
          end
        end

        @services
      end
    end
  end
end
