require "rails_helper"

RSpec.describe Creators::EmploymentsCreator do
  let(:assessment) { create :assessment }

  let(:creator) { described_class.new(assessment_id: assessment.id, employments_params: params) }

  context "with client ids" do
    let(:params) { employment_income_params }

    it "creates the expected employment records" do
      expect { creator.call }.to change(Employment, :count).by(2)
      expect(Employment.all.map(&:client_id)).to match_array %w[employment-id-1 employment-id-2]
    end

    it "creates the expected employment_payment records" do
      expect { creator.call }.to change(EmploymentPayment, :count).by(6)
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
          payments: [
            {
              client_id: "employment-1-payment-1",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
              net_employment_income: 898.84,
            },
            {
              client_id: "employment-1-payment-2",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
              net_employment_income: 898.84,
            },
            {
              client_id: "employment-1-payment-3",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
              net_employment_income: 898.84,
            },
          ],
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
              net_employment_income: 898.84,
            },
            {
              client_id: "employment-2-payment-2",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
              net_employment_income: 898.84,
            },
            {
              client_id: "employment-2-payment-3",
              date: "2021-10-30",
              gross: 1046.00,
              benefits_in_kind: 16.60,
              tax: -104.10,
              national_insurance: -18.66,
              net_employment_income: 898.84,
            },
          ],
        },
      ],
    }
  end
end
