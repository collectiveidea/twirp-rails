# frozen_string_literal: true

using Twirp::Rails::Rescuable

RSpec.describe Twirp::Rails::Rescuable do
  let(:rescuer) do
    Class.new do
      include ActiveSupport::Rescuable

      rescue_from ArgumentError do |error|
        Twirp::Error.invalid_argument(error.message)
      end
    end.new
  end

  def raised(exception, cause: nil)
    raise exception, cause: cause
  rescue => raised_exception
    raised_exception
  end

  describe "#rescue_with_handler_and_return" do
    it "returns the result of the handler for the exception" do
      exception = raised(ArgumentError.new("is way too large"))

      expect(rescuer.rescue_with_handler_and_return(exception)).to have_attributes(code: :invalid_argument, msg: "is way too large")
    end

    it "returns the result of the handler for the exception's cause" do
      exception = raised(RuntimeError.new("hat factory failed"), cause: raised(ArgumentError.new("is way too large")))

      expect(rescuer.rescue_with_handler_and_return(exception)).to have_attributes(code: :invalid_argument, msg: "is way too large")
    end

    it "returns the result of the handler for a cause further down the chain" do
      cause = raised(RuntimeError.new("hat factory failed"), cause: raised(ArgumentError.new("is way too large")))
      exception = raised(RuntimeError.new("hat shop failed"), cause: cause)

      expect(rescuer.rescue_with_handler_and_return(exception)).to have_attributes(code: :invalid_argument, msg: "is way too large")
    end

    it "returns nil when no handler matches the exception or its causes" do
      exception = raised(RuntimeError.new("hat shop failed"), cause: raised(KeyError.new("no such hat")))

      expect(rescuer.rescue_with_handler_and_return(exception)).to be_nil
    end
  end
end
