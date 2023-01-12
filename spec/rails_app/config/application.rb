require "active_record/railtie"

module RailsApp
  class Application < Rails::Application
    config.root = File.expand_path("../../", __FILE__)
    config.active_record.legacy_connection_handling = false
  end
end
