module Twirp
  module Rails
    module Rack
      # Middleware that enables conditional POST using If-None-Match and
      # If-Modified-Since. The application should set either or both of the
      # Last-Modified or Etag response headers according to RFC 2616. When
      # either of the conditions is met, the response body is set to be zero
      # length and the response status is set to 304 Not Modified.
      #
      # Applications that defer response body generation until the body's each
      # message is received will avoid response body generation completely when
      # a conditional POST matches.
      #
      # Based on Rack::ConditionalGet
      #
      # Twirp requests are, be design, always POST.
      # We want the logic of Rack::ConditionalGet but applied to POSTs.
      #
      # Not all Twirp calls are idemtpotent, so it is left up to the client
      # to know when 304 Not Modified responses are desirable, and send the
      # appropriate header(s).
      class ConditionalPost < ::Rack::ConditionalGet
        # Return empty 304 response if the response has not been
        # modified since the last request.
        def call(env)
          case env[::Rack::REQUEST_METHOD]
          when "POST"
            status, headers, body = @app.call(env)
            headers = ::Rack::Utils::HeaderHash[headers]
            if status == 200 && fresh?(env, headers)
              status = 304
              headers.delete(::Rack::CONTENT_TYPE)
              headers.delete(::Rack::CONTENT_LENGTH)
              original_body = body
              body = ::Rack::BodyProxy.new([]) do
                original_body.close if original_body.respond_to?(:close)
              end
            end
            [status, headers, body]
          else
            @app.call(env)
          end
        end
      end
    end
  end
end
