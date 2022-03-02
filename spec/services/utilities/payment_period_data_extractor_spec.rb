require "rails_helper"

module Utilities
  RSpec.describe PaymentPeriodDataExtractor do
    it "returns an array of dates and amounts" do
      payments = [
        create(:other_income_payment, payment_date: 2.months.ago.to_date, amount: 501.77),
        create(:other_income_payment, payment_date: 1.month.ago.to_date, amount: 502.66),
        create(:other_income_payment, payment_date: Date.current, amount: 505.0),
      ]
      expected_results = [
        [2.months.ago.to_date, 501.77],
        [1.month.ago.to_date, 502.66],
        [Date.current, 505.0],
      ]
      expect(described_class.call(collection: payments, date_method: :payment_date, amount_method: :amount)).to eq expected_results
    end
  end
end
