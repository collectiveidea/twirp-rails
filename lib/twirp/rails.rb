# frozen_string_literal: true

require_relative "rails/version"

module Twirp
  module Rails
    class Error < StandardError; end
    # Your code goes here...
  end
end

require "twirp"
require "active_support/notifications"
require_relative "rails/callbacks"
require_relative "rails/configuration"
require_relative "rails/dispatcher"
require_relative "rails/engine"
require_relative "rails/rescuable"
require_relative "rails/handler"

module Twirp
  class Service
    # Override initialize to make handler argument optional.
    # When left nil, we will use our dispatcher.
    alias_method :original_initialize, :initialize
    def initialize(handler = nil)
      handler ||= Twirp::Rails::Dispatcher.new(self.class)
      original_initialize(handler)
    end
  end
end
