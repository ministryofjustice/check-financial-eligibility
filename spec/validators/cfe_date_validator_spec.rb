require "rails_helper"

class DummyClass
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :date_val

  validates :date_val, cfe_date: { not_in_the_future: true }
end

RSpec.describe CFEDateValidator do
  describe "not_in_the_future validation" do
    let(:dummy) { DummyClass.new }

    it "raises error if date is in the future" do
      dummy.date_val = 3.days.from_now.to_date
      expect(dummy).to be_invalid
      expect(dummy.errors[:date_val]).to eq ["cannot be in the future"]
    end

    it "does not raise an error if date is not in the future" do
      dummy.date_val = 3.days.ago.to_date
      expect(dummy).to be_valid
      expect(dummy.errors[:date_val]).to eq []
    end

    it "does not raise an error if date is today" do
      dummy.date_val = Time.zone.today
      expect(dummy).to be_valid
      expect(dummy.errors[:date_val]).to eq []
    end

    it "does not raise an error if date is a valid date string" do
      dummy.date_val = 3.days.ago.to_date.to_s
      expect(dummy).to be_valid
      expect(dummy.errors[:date_val]).to eq []
    end

    it "raises an error if date is an invalid date string" do
      dummy.date_val = "invalid"
      expect(dummy).to be_invalid
      expect(dummy.errors[:date_val]).to eq ["date not valid"]
    end
  end
end
