require "rails_helper"

RSpec.describe EmploymentPayment, type: :model do
  it "validates net income as positive" do
    expect(build(:employment_payment, gross_income: 34, tax: -1500.0)).not_to be_valid
  end
end
