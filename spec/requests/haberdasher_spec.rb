require "spec_helper"

RSpec.describe "Haberdasher Service", type: :request do
  it "makes a hat" do
    size = Twirp::Example::Haberdasher::Size.new(inches: 24)

    post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
      params: size.to_proto, headers: {
        :accept => "application/protobuf",
        "Content-Type" => "application/protobuf"
      }
    expect(response).to be_successful
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
            handler: an_instance_of(HaberdasherHandler),
            env: an_instance_of(Hash),
            request: an_instance_of(Twirp::Example::Haberdasher::Size)
          }),
        have_attributes(name: "handler_run_callbacks.twirp_rails",
          payload: {
            handler: an_instance_of(HaberdasherHandler),
            env: an_instance_of(Hash),
            request: an_instance_of(Twirp::Example::Haberdasher::Size)
          })
      )

      # In order that events were initialized
      expect(@events.sort_by(&:time).map(&:name)).to contain_exactly("handler_run.twirp_rails", "handler_run_callbacks.twirp_rails")
    end
  end
end
