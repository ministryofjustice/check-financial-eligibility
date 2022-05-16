require "rails_helper"

RSpec.describe CurrencyValidator, type: :validator do
  subject(:foo_instance) { foo_model.new(currency_field: currency_value) }

  let(:foo_model) do
    Class.new do
      include ActiveModel::Model
      # include ActiveModel::Validations

      def self.name
        "FooModel"
      end

      attr_accessor :currency_field

      validates :currency_field, currency: { greater_than_or_equal_to: 0 }, allow_blank: true
    end
  end

  context "with integer values" do
    let(:currency_value) { 10 }

    it "is valid" do
      expect(foo_instance).to be_valid
      expect(foo_instance.errors[:currency_field]).to eq []
    end
  end

  context "with string values" do
    let(:currency_value) { "foo" }

    it "is invalid" do
      expect(foo_instance).to be_invalid
      expect(foo_instance.errors[:currency_field]).to include("Must be a decimal with a maximum of two decimal places. For example: 123.34")
    end
  end

  context "with negative values" do
    let(:currency_value) { -33.55 }

    it "is valid" do
      expect(foo_instance).to be_valid
      expect(foo_instance.errors[:currency_field]).to eq []
    end
  end

  context "with not_negative option" do
    let(:foo_model) do
      Class.new do
        include ActiveModel::Model

        def self.name
          "FooModel"
        end

        attr_accessor :currency_field

        validates :currency_field, currency: { greater_than_or_equal_to: 0, not_negative: true }, allow_blank: true
      end
    end

    context "with negative values" do
      let(:currency_value) { -10 }

      it "is invalid" do
        expect(foo_instance).to be_invalid
        expect(foo_instance.errors[:currency_field]).to include("Must be a decimal, zero or greater, with a maximum of two decimal places. For example: 123.34")
      end
    end

    context "with positive values" do
      let(:currency_value) { 10 }

      it "is valid" do
        expect(foo_instance).to be_valid
        expect(foo_instance.errors[:currency_field]).to eq []
      end
    end
  end
end
