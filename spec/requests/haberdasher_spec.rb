require "spec_helper"

RSpec.describe "Haberdasher Service", type: :request do
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
    decoded = Twirp::Example::Haberdasher::Hat.decode(response.body)
    expect(decoded).to be_a(Twirp::Example::Haberdasher::Hat)
  end

  it "makes a hat" do
    make_hat_success_request
    expect(log).to have_received(:write).with(/INFO -- : Twirp 200 in \dms as application\/protobuf/)
    expect(log).to have_received(:write).with(a_string_matching("DEBUG -- : Twirp Response: <Twirp::Example::Haberdasher::Hat: inches: 24, color: \"Tan\", name: \"Pork Pie\">"))
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

      expect(log).to have_received(:write).with(/INFO -- : Twirp 400 in \d+ms as application\/json/)
      expect(log).to have_received(:write).with(a_string_matching("DEBUG -- : Twirp Response: <Twirp::Error code:invalid_argument msg:\"is too small\" meta:#{{argument: "inches"}}>")) # standard:disable Lint/LiteralInInterpolation
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

      expect(log).to have_received(:write).with(/INFO -- : Twirp 400 in \d+ms as application\/json/)
      expect(log).to have_received(:write).with(a_string_matching("DEBUG -- : Twirp Response: <Twirp::Error code:invalid_argument msg:\"is too big\" meta:#{{argument: "inches"}}>")) # standard:disable Lint/LiteralInInterpolation
    end

    it "deals with unhandled exceptions" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 1_234) # Special size that raises an exception

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf"
        }

      expect(response.status).to eq(500)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq('{"code":"internal","msg":"Contrived Example Error","meta":{"cause":"RuntimeError"}}')

      expect(log).to have_received(:write).with(/INFO -- : Twirp 500 in \d+ms as application\/json/)
      expect(log).to have_received(:write).with(/ERROR -- : Twirp Exception \(RuntimeError: Contrived Example Error\)\n.*in.*reject_giant_hats'/)
      expect(log).to have_received(:write).with(a_string_matching("DEBUG -- : Twirp Response: <Twirp::Error code:internal msg:\"Contrived Example Error\" meta:#{{cause: "RuntimeError"}}>")) # standard:disable Lint/LiteralInInterpolation
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
      expect(response.headers["vary"]).to eq("Accept-Encoding")
      expect(response.headers["content-encoding"]).to eq("gzip")

      expect(log).to have_received(:write).with(/INFO -- : Twirp 200 in \d+ms as application\/protobuf with content-encoding: gzip/)
      expect(log).to have_received(:write).with(a_string_matching('DEBUG -- : Twirp Response: <Twirp::Example::Haberdasher::Hat: inches: 24, color: "Tan", name: "Pork Pie">'))
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

  describe "caching" do
    it "respects cache headers to return 304 statuses" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 24)

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf"
        }
      expect(response).to be_successful
      decoded = Twirp::Example::Haberdasher::Hat.decode(response.body)
      expect(decoded).to be_a(Twirp::Example::Haberdasher::Hat)
      expect(response.etag).to be_present

      expect(log).to have_received(:write).with(/INFO -- : Twirp 200 in \d+ms as application\/protobuf/)
      expect(log).to have_received(:write).with(a_string_matching('DEBUG -- : Twirp Response: <Twirp::Example::Haberdasher::Hat: inches: 24, color: "Tan", name: "Pork Pie">'))

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf",
          "If-None-Match" => response.etag
        }

      expect(response.status).to eq(304)
      expect(log).to have_received(:write).with(/INFO -- : Twirp 304 in \d+ms/)
      expect(log).to have_received(:write).with(a_string_matching('DEBUG -- : Twirp Response: <Twirp::Example::Haberdasher::Hat: inches: 24, color: "Tan", name: "Pork Pie">')).twice # once from before, once for the 304
    end
  end

  describe "Rescuable" do
    it "rescues from ArgumentError" do
      size = Twirp::Example::Haberdasher::Size.new(inches: 100)

      # Fake an exception
      expect(Twirp::Example::Haberdasher::Hat).to receive(:new).and_raise(ArgumentError.new("is way too large"))

      post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
        params: size.to_proto, headers: {
          :accept => "application/protobuf",
          "Content-Type" => "application/protobuf"
        }

      expect(response.status).to eq(400)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq('{"code":"invalid_argument","msg":"is way too large"}')
    end
  end
end
