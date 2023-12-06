Rails.application.config.twirp.service_hooks[:before] = lambda do |rack_env, env|
  # Make IP accessible to the handlers
  env[:ip] = rack_env["REMOTE_ADDR"]
end

Rails.application.config.twirp.middleware = [
  Rack::Deflater
]
