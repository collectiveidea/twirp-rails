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

          logging_hooks = {
            before: proc { |rack_env, env|
              env[:request_start_time] = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
              [rack_env, env]
            },
            on_success: proc { |env|
              request_time = duration_in_ms(env[:request_start_time])
              ::Rails.logger.info("Twirp success in #{request_time}ms")
              env
            },
            on_error: proc { |error, env|
              request_time = duration_in_ms(env[:request_start_time])
              http_code = Twirp::ERROR_CODES_TO_HTTP_STATUS[error.code]
              ::Rails.logger.info("Twirp #{error.code} (#{http_code}) in #{request_time}ms (#{error.code}: #{error.msg} - #{error.meta})")
              [error, env]
            },
            exception_raised: proc { |exception, env|
              request_time = duration_in_ms(env[:request_start_time])
              ::Rails.logger.info("Twirp exception (500) in #{request_time}ms (#{exception.class}: #{exception.message})")
              [exception, env]
            }
          }

          # Install hooks that may be defined in the config
          hook_names = [:before, :on_success, :on_error, :exception_raised].freeze
          @services.each do |service|
            hook_names.each do |hook_name|
              hook = ::Rails.application.config.twirp.service_hooks[hook_name]
              if hook
                # Lambda compositions with array returns is weird. Avoid it.
                raise "Define your #{hook_name} hook as a proc, not a lambda." if hook.lambda?

                # Compose user hook with logging hook to run both
                composition = logging_hooks[hook_name] >> hook
                service.send(hook_name, &composition)
              else
                service.send(hook_name, &logging_hooks[hook_name])
              end
            end
          end
        end

        @services
      end

      def duration_in_ms(time)
        ((::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - time) * 1000).to_i
      end
    end
  end
end
