Rails.application.routes.draw do
  mount Twirp::Rails::Engine, at: "/twirp"

  get "up" => "rails/health#show", :as => :rails_health_check
end
