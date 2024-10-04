# frozen_string_literal: true

module Twirp
  module Rails
    module Rescuable
      refine ::ActiveSupport::Rescuable::ClassMethods do
        # A slightly altered version of ActiveSupport::Rescuable#rescue_with_handler
        # that returns the result rather than the handled exception
        def rescue_with_handler_and_return(exception, object: self, visited_exceptions: [])
          visited_exceptions << exception

          if (handler = handler_for_rescue(exception, object: object))
            handler.call exception
          elsif exception
            if visited_exceptions.include?(exception.cause)
              nil
            else
              rescue_with_handler(exception.cause, object: object, visited_exceptions: visited_exceptions)
            end
          end
        end
      end

      refine ::ActiveSupport::Rescuable do
        def rescue_with_handler_and_return(exception)
          self.class.rescue_with_handler_and_return exception, object: self
        end
      end
    end
  end
end
