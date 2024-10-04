require "ip_tracker"
class HaberdasherHandler < Twirp::Rails::Handler
  before_action :track_request_ip
  before_action :reject_giant_hats

  rescue_from "ArgumentError" do |error|
    Twirp::Error.invalid_argument(error.message)
  end

  def make_hat
    # We can return a Twirp::Error when appropriate
    if request.inches < 12
      return Twirp::Error.invalid_argument("is too small", argument: "inches")
    end

    # Build the reponse
    Twirp::Example::Haberdasher::Hat.new(
      inches: request.inches,
      name: "Pork Pie",
      color: "Tan"
    )
  end

  private

  # Contrived example of using a before_action with data that
  # comes from a :before service hook.
  def track_request_ip
    IPTracker.track(env[:ip])
  end

  # contrived example of using a before_action
  def reject_giant_hats
    if request.inches >= 1_000
      Twirp::Error.invalid_argument("is too big", argument: "inches")
    end
  end
end
