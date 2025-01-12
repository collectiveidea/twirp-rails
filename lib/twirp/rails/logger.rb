# frozen_string_literal: true

module Twirp
  module Rails
    class Logger
      def initialize(app)
        @app = app
      end

      def call(env)
        start_time = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
        @app.call(env).tap do |response|
          ::Rails.logger.info("Twirp #{response.first} in #{duration_in_ms(start_time)}ms as #{response.second["content-type"]}")
          ::Rails.logger.debug(response.last.first) # Response body
        end
      end

      def duration_in_ms(time)
        ((::Process.clock_gettime(::Process::CLOCK_MONOTONIC) - time) * 1000).to_i
      end
    end
  end
end
