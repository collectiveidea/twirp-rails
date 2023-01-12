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
  end
end
