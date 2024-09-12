module Twirp
  module Example
    module Cobbler
      class CobblerHandler < Twirp::Rails::Handler
        def make_shoe
          # We can return a Twirp::Error when appropriate
          if request.inches < 12
            return Twirp::Error.invalid_argument("is too small", argument: "inches")
          end

          # Build the reponse
          Twirp::Example::Cobbler::Shoe.new(
            inches: request.inches,
            name: "Pork Pie",
            color: "Tan"
          )
        end
      end
    end
  end
end
