require "spec_helper"

RSpec.describe "Haberdasher Service", type: :request do
  def make_hat_success_request
    size = Twirp::Example::Haberdasher::Size.new(inches: 24)

    post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
      params: size.to_proto, headers: {
        :accept => "application/protobuf",
        "Content-Type" => "application/protobuf"
      }
    expect(response).to be_successful
    decoded = Twirp::Example::Haberdasher::Hat.decode(response.body)
    expect(decoded).to be_a(Twirp::Example::Haberdasher::Hat)
  end

  it "makes a hat" do
    make_hat_success_request
  end

  describe "error handling" do
    it "allows a handler to return a Twirp::Error" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 6)

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf"
        }

      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq('{"code":"invalid_argument","msg":"is too small","meta":{"argument":"inches"}}')
    end

    it "allows a before_action to return a Twirp::Error" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 12_000)

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf"
        }

      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq('{"code":"invalid_argument","msg":"is too big","meta":{"argument":"inches"}}')
    end
  end

  describe "notifications" do
    before do
      @events = []
      @subscriber = ActiveSupport::Notifications.subscribe(/twirp_rails/) do |*args|
        @events << ActiveSupport::Notifications::Event.new(*args)
      end
    end

    after do
      ActiveSupport::Notifications.unsubscribe(@subscriber)
    end

    it "publishes ActiveSupport::Notifications for the handler" do
      make_hat_success_request

      expect(@events).to contain_exactly(
        have_attributes(name: "handler_run.twirp_rails",
          payload: {
            handler: "HaberdasherHandler",
            action: "make_hat",
            env: an_instance_of(Hash),
            request: an_instance_of(Twirp::Example::Haberdasher::Size),
            response: an_instance_of(Twirp::Example::Haberdasher::Hat)
          }),
        have_attributes(name: "handler_run_callbacks.twirp_rails",
          payload: {
            handler: "HaberdasherHandler",
            action: "make_hat",
            env: an_instance_of(Hash),
            request: an_instance_of(Twirp::Example::Haberdasher::Size)
          })
      )

      # In order that events were initialized
      expect(@events.sort_by(&:time).map(&:name)).to contain_exactly("handler_run.twirp_rails", "handler_run_callbacks.twirp_rails")
    end
  end

  describe "service hooks" do
    it "can inject data via a before hook" do
      expect(IPTracker).to receive(:track).with("127.0.0.1")
      make_hat_success_request
    end
  end

  describe "middleware" do
    it "runs injected middleware when appropriate" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 24)

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf",
          "Accept-Encoding" => "gzip" # ask for GZIP encoding
        }
      expect(response.headers["Vary"]).to eq("Accept-Encoding")
      expect(response.headers["Content-Encoding"]).to eq("gzip")
    end

    it "ignores injected middleware when inappropriate" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 24)

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf"
          # no encoding specified
        }
      expect(response.headers["Vary"]).to eq("Accept-Encoding")
      expect(response.headers["Content-Encoding"]).to be_nil
    end
  end
end
