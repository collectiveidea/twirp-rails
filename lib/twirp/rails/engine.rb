# frozen_string_literal: true

require "rails/engine"
require "rack/etag"
require_relative "rack/conditional_post"

module Twirp
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Twirp::Rails
      engine_name "twirp"
      # endpoint MyRackApplication
      # # Add a load path for this specific Engine
      # config.autoload_paths << File.expand_path("lib/some/path", __dir__)

      config.twirp = Configuration.new

      initializer "twirp.configure.defaults", before: "twirp.configure" do |app|
        twirp = app.config.twirp
        # twirp.auto_mount = true if twirp.auto_mount.nil?
        twirp.load_paths ||= ["lib"]
      end

      initializer "twirp.configure" do |app|
        [:auto_mount, :endpoint, :load_paths, :middleware, :service_hooks].each do |key|
          app.config.twirp.send(key)
        end

        # Set up logging
        app.config.middleware.use app.config.twirp.logger, ::Rails.logger
        app.config.twirp.verbose_logging = ::Rails.logger.level == ::Logger::DEBUG if app.config.twirp.verbose_logging.nil?

        app.config.twirp.middleware.each do |middleware|
          app.config.middleware.use middleware
        end

        # Load all Twirp files
        app.config.twirp.load_paths.each do |directory|
          ::Rails.root.glob("#{directory}/**/*_twirp.rb").sort.each { |file| require file }
        end
      end
    end

    class << self
      def services
        if @services.nil?
          @services = Twirp::Service.subclasses.map(&:new)

          # Install hooks that may be defined in the config
          @services.each do |service|
            # Add user-defined hooks
            ::Rails.application.config.twirp.service_hooks.each do |hook_name, hook|
              service.send(hook_name, &hook)
            end

            # Add our own logging hooks if verbose_logging is enabled
            if ::Rails.application.config.twirp.verbose_logging
              service.on_success do |env|
                ::Rails.logger.debug("Twirp Response: #{env[:output].inspect}")
              end

              service.on_error do |error, _env|
                ::Rails.logger.debug("Twirp Response: #{error.inspect}")
              end

              service.exception_raised do |exception, _env|
                ::Rails.logger.debug("Twirp Exception (#{exception.class}: #{exception.message})\n#{exception.backtrace.join("\n")}")
              end
            end
          end
        end

        @services
      end
    end
  end
end
