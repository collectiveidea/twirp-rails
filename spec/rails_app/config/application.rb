require "rails"
require "action_controller/railtie"

Bundler.require
require "twirp/on/rails" # test it how a typical install would require it
# require "twirp/rails"

module RailsApp
  class Application < Rails::Application
    config.root = File.expand_path("../../", __FILE__)

    config.twirp.verbose_logging = true
  end
end
