Twirp::Rails::Engine.routes.draw do
  Twirp::Rails.services.each do |service|
    mount service, at: service.full_name
  end
end
