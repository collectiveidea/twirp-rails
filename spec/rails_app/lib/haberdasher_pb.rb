# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: lib/haberdasher.proto

require "google/protobuf"

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("lib/haberdasher.proto", syntax: :proto3) do
    add_message "twirp.example.haberdasher.Size" do
      optional :inches, :int32, 1
    end
    add_message "twirp.example.haberdasher.Hat" do
      optional :inches, :int32, 1
      optional :color, :string, 2
      optional :name, :string, 3
    end
  end
end

module Twirp
  module Example
    module Haberdasher
      Size = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("twirp.example.haberdasher.Size").msgclass
      Hat = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("twirp.example.haberdasher.Hat").msgclass
    end
  end
end
