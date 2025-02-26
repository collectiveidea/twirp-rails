# frozen_string_literal: true

require "twirp"
require "active_support/notifications"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem_extension(Twirp)
loader.ignore("#{__dir__}/on/rails.rb")
loader.setup

module Twirp::Rails
end

loader.eager_load

Twirp::Service.class_eval do
  # Override initialize to make handler argument optional.
  # When left nil, we will use our dispatcher.
  alias_method :original_initialize, :initialize
  def initialize(handler = nil)
    handler ||= Twirp::Rails::Dispatcher.new(self.class)
    original_initialize(handler)
  end

  # Override inspect to show all available RPCs
  # This is used when displaying routes.
  def inspect
    self.class.rpcs.map { |rpc| "#{self.class.name.demodulize.underscore}_handler##{rpc[1][:ruby_method]}" }.join("\n")
  end
end
