module Twirp
  module Rails
    # = Twirp Rails Callbacks
    #
    # Based on Abstract Controller Callbacks with the terminator changed.
    #
    # A before_action that returns a Twirp::Error will halt the action.
    #
    # Abstract Controller provides hooks during the life cycle of a controller action.
    # Callbacks allow you to trigger logic during this cycle. Available callbacks are:
    #
    # * <tt>after_action</tt>
    # * <tt>append_after_action</tt>
    # * <tt>append_around_action</tt>
    # * <tt>append_before_action</tt>
    # * <tt>around_action</tt>
    # * <tt>before_action</tt>
    # * <tt>prepend_after_action</tt>
    # * <tt>prepend_around_action</tt>
    # * <tt>prepend_before_action</tt>
    # * <tt>skip_after_action</tt>
    # * <tt>skip_around_action</tt>
    # * <tt>skip_before_action</tt>
    #
    # NOTE: Calling the same callback multiple times will overwrite previous callback definitions.
    #
    module Callbacks
      extend ActiveSupport::Concern

      include AbstractController::Callbacks

      included do
        define_callbacks :process_action,
          terminator: ->(controller, result_lambda) {
            # save off the error and terminate if a callback returns a Twirp::Error
            result = result_lambda.call
            if result.is_a?(Twirp::Error)
              controller.error = result
              true
            else
              false
            end
          },
          skip_after_callbacks_if_terminated: true
      end
    end
  end
end
