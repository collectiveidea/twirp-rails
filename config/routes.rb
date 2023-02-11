Rails.application.routes.draw do
  if Rails.application.config.twirp.auto_mount
    mount Twirp::Rails::Engine => Rails.application.config.twirp.endpoint
  end
end

Twirp::Rails::Engine.routes.draw do
  Twirp::Rails.services.each do |service|
    mount service, at: service.full_name
  end
end
