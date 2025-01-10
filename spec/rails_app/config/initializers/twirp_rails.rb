Rails.application.config.twirp.service_hooks[:before] = proc do |rack_env, env|
  # Make IP accessible to the handlers
  env[:ip] = rack_env["REMOTE_ADDR"]
end

Rails.application.config.twirp.middleware = [
  Rack::Deflater,
  Twirp::Rails::Rack::ConditionalPost,
  Rack::ETag
]
