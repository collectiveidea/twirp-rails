# frozen_string_literal: true

RSpec.describe Twirp::Rails::Handler do
  let(:handler_class) do
    Class.new(described_class) do
      rescue_from ArgumentError do |error|
        Twirp::Error.invalid_argument(error.message)
      end

      def make_hat
        :hat
      end
    end
  end

  def make_hat
    handler_class.new.process(:make_hat, nil, {})
  end

  describe "rescue_from" do
    it "rescues an exception raised in the action, skipping the callbacks after it" do
      ran = []
      handler_class.around_action do |_handler, action|
        action.call
        ran << :around_action
      end
      handler_class.after_action { ran << :after_action }
      handler_class.define_method(:make_hat) { raise ArgumentError, "from the action" }

      expect(make_hat).to have_attributes(code: :invalid_argument, msg: "from the action")
      expect(ran).to be_empty
    end

    it "rescues an exception raised in a before_action" do
      handler_class.before_action { raise ArgumentError, "from a before_action" }

      expect(make_hat).to have_attributes(code: :invalid_argument, msg: "from a before_action")
    end

    it "rescues an exception raised in an around_action" do
      handler_class.around_action { raise ArgumentError, "from an around_action" }

      expect(make_hat).to have_attributes(code: :invalid_argument, msg: "from an around_action")
    end

    it "rescues an exception raised in an after_action" do
      handler_class.after_action { raise ArgumentError, "from an after_action" }

      expect(make_hat).to have_attributes(code: :invalid_argument, msg: "from an after_action")
    end
  end
end
