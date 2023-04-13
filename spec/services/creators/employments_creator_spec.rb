require "rails_helper"

RSpec.describe Creators::EmploymentsCreator do
  let(:assessment) { create :assessment }

  context "with negative net income" do
    let(:creator) do
      described_class.call(employments_params: employment_income_params,
                           employment_collection: assessment.employments)
    end

    let(:job1_payments) do
      [
        {
          client_id: "employment-1-payment-1",
          date: "2021-10-30",
          gross: 146.00,
          benefits_in_kind: 16.60,
          tax: -164.10,
          national_insurance: -18.66,
        },
      ]
    end

    it "returns an error" do
      expect(creator.errors).to eq(["Net income must be greater than or equal to 0"])
    end
  end

  context "with client ids" do
    let(:job1_payments) do
      [
        {
          client_id: "employment-1-payment-1",
          date: "2021-10-30",
          gross: 1046.00,
          benefits_in_kind: 16.60,
          tax: -104.10,
          national_insurance: -18.66,
        },
        {
          client_id: "employment-1-payment-2",
          date: "2021-10-30",
          gross: 1046.00,
          benefits_in_kind: 16.60,
          tax: -104.10,
          national_insurance: -18.66,
        },
        {
          client_id: "employment-1-payment-3",
          date: "2021-10-30",
          gross: 1046.00,
          benefits_in_kind: 16.60,
          tax: -104.10,
          national_insurance: -18.66,
        },
      ]
    end

    before do
      described_class.call(employments_params: employment_income_params, employment_collection: assessment.employments)
    end

    it "creates the expected employment records" do
      expect(Employment.all.map(&:client_id)).to match_array %w[employment-id-1 employment-id-2]
      expect(Employment.find_by(client_id: "employment-id-1")).to be_receiving_only_statutory_sick_or_maternity_pay
    end

    it "creates the expected employment_payment records" do
      expect(EmploymentPayment.count).to eq(6)
      expect(EmploymentPayment.all.map(&:client_id)).to match_array expected_employment_payment_ids
    end
  end

  def expected_employment_payment_ids
    %w[employment-1-payment-1 employment-1-payment-2 employment-1-payment-3 employment-2-payment-1 employment-2-payment-2 employment-2-payment-3]
  end

  def employment_income_params
    {
      employment_income: [
        {
          name: "Job 1",
          client_id: "employment-id-1",
          receiving_only_statutory_sick_or_maternity_pay: true,
          payments: job1_payments,
        },
        {
          name: "Job 2",
          client_id: "employment-id-2",
          payments: [
            {
              client_id: "employment-2-payment-1",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
            },
            {
              client_id: "employment-2-payment-2",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
            },
            {
              client_id: "employment-2-payment-3",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
            },
          ],
        },
      ],
    }
  end
end
