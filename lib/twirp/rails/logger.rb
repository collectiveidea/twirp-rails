# frozen_string_literal: true

# Rack::CommonLogger is nice but we can do better.
# Rails doesn't use it, but we need to log Twirp requests.
# Here's an example from Rack::CommonLogger:
#   127.0.0.1 - - [12/Jan/2025:17:09:49 -0500] "POST /twirp/twirp.example.haberdasher.Haberdasher/MakeHat HTTP/1.0" 200 - 439.0060
#
# Rails gives us this:
#   Started POST "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat" for 127.0.0.1 at 2025-01-12 22:48:00 -0500
# but we also want to know the result of the Twirp call.
# Here's what this Logger adds:
#   Twirp 200 in 2ms as application/protobuf
#
# If the logger is in debug mode, it also outputs the response body.

module Twirp
  module Rails
    class Logger < ::Rack::CommonLogger
      def call(env)
        super.tap do |(status, headers, body)|
          # If the logger is in debug mode, log the response body.
          if @logger.level == ::Logger::DEBUG && !::Rack::Utils::STATUS_WITH_NO_ENTITY_BODY[status] && headers["content-encoding"].nil?
            log_response_body(body)
          end
        end
      end

      private

      def log(env, status, response_headers, began_at)
        content_type = response_headers["content-type"].presence
        content_encoding = response_headers["content-encoding"].presence
        @logger.info("Twirp #{status} in #{duration_in_ms(began_at)}ms#{" as #{content_type}" if content_type}#{" with content-encoding: #{content_encoding}" if content_encoding}")
      end

      def log_response_body(body)
        body = [body.to_str] if body.respond_to?(:to_str)
        @logger.debug("Twirp Response: #{body.join}")
      end

      def duration_in_ms(time)
        ((::Rack::Utils.clock_time - time) * 1000).to_i
      end
    end
  end
end
