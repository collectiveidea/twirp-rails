Rails.application.routes.draw do
  mount Twirp::Rails::Engine, at: "/twirp"
end
