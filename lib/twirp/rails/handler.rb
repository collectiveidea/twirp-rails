# frozen_string_literal: true

module Twirp
  module Rails
    class Handler
      include Twirp::Rails::Callbacks
      include ActiveSupport::Rescuable
      using Twirp::Rails::Rescuable

      attr_reader :request, :env
      attr_reader :action_name
      attr_accessor :error

      # @param name [Symbol] The method name to invoke in the handler
      # @param request [Object] The protobuf message request parameter
      # @param env [Hash] The Twirp environment
      def process(name, request, env)
        @request = request
        @env = env
        @error = nil
        @action_name = name.to_s

        response = process_action(action_name)
        error || response
      end

      private

      # Call the action. Override this in a subclass to modify the
      # behavior around processing an action. This, and not #process,
      # is the intended way to override action dispatching.
      #
      # Notice that the first argument is the method to be dispatched
      # which is *not* necessarily the same as the action name.
      def process_action(name)
        ActiveSupport::Notifications.instrument("handler_run_callbacks.twirp_rails", handler: self.class.name, action: action_name, env: @env, request: @request) do
          run_callbacks(:process_action) do
            ActiveSupport::Notifications.instrument("handler_run.twirp_rails", handler: self.class.name, action: action_name, env: @env, request: @request) do |payload|
              payload[:response] = begin
                send_action(name)
              rescue => exception
                rescue_with_handler_and_return(exception) || raise
              end
            end
          end
        end
      end

      # Actually call the method associated with the action. Override
      # this method if you wish to change how action methods are called,
      # not to add additional behavior around it. For example, you would
      # override #send_action if you want to inject arguments into the
      # method.
      alias_method :send_action, :send
    end
  end
end
