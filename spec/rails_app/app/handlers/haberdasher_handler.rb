class HaberdasherHandler < Twirp::Rails::Handler
  def make_hat
    Twirp::Example::Haberdasher::Hat.new(
      inches: request.inches,
      name: "Pork Pie",
      color: "Tan"
    )
  end
end
