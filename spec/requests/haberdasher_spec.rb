require "spec_helper"

RSpec.describe "Haberdasher Service", type: :request do
  it "makes a hat" do
    size = Twirp::Example::Haberdasher::Size.new(inches: 12)

    post "/twirp/twirp.example.haberdasher.Haberdasher/MakeHat",
      params: size.to_proto, headers: {
        :accept => "application/protobuf",
        "Content-Type" => "application/protobuf"
      }
    expect(response).to be_successful
  end
end
