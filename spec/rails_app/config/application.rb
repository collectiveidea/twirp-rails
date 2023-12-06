require "rails"
require "action_controller/railtie"
require "active_record/railtie"

Bundler.require
require "twirp/rails"

module RailsApp
  class Application < Rails::Application
    config.root = File.expand_path("../../", __FILE__)
  end
end
