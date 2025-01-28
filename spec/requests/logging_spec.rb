require "spec_helper"

# haberdasher_spec covers logging in most cases, but this file tests other situations
RSpec.describe "Logging", type: :request do
  let!(:log) { StringIO.new }

  before do
    ::Rails.logger.broadcast_to(::Logger.new(log))
    allow(log).to receive(:write).and_call_original
  end

  def make_hat_success_request
    size = Twirp::Example::Haberdasher::Size.new(inches: 24)

    post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
      params: size.to_proto, headers: {
        :accept => "application/protobuf",
        "Content-Type" => "application/protobuf"
      }
    expect(response).to be_successful
  end

  describe "with the default logger" do
    it "logs with the default logger" do
      make_hat_success_request
      expect(log).to have_received(:write).with(/INFO -- : Twirp 200 in \dms as application\/protobuf/)
      expect(log).to have_received(:write).with(a_string_matching("DEBUG -- : Twirp Response: <Twirp::Example::Haberdasher::Hat: inches: 24, color: \"Tan\", name: \"Pork Pie\">"))
    end

    it "does not log non-Twirp requests" do
      get "/up"
      expect(log).not_to have_received(:write).with(/Twirp/)
    end
  end
end
