require "rails_helper"

module Creators
  RSpec.describe StateBenefitsCreator do
    describe ".call" do
      let(:assessment) { create :assessment, :with_gross_income_summary }
      let!(:state_benefit_type1) { create :state_benefit_type }
      let!(:state_benefit_type2) { create :state_benefit_type }
      let!(:state_benefit_type3) { create :state_benefit_type }
      let(:state_benefits) { state_benefits_params }

      subject(:creator) { described_class.call(assessment_id: assessment.id, state_benefits_params: state_benefits_params.to_json) }

      it "creates all the required state benefits records" do
        expect { creator }.to change(StateBenefitPayment, :count).by(6)
      end

      context "with invalid date" do
        let(:state_benefits_params) do
          {
            state_benefits: [
              {
                name: state_benefit_type1.label,
                payments: [
                  { date: 3.days.from_now.to_date, amount: 266.95, client_id: "abc123" },
                ],
              },
            ],
          }
        end

        it "returns an error" do
          expect(creator.errors).to eq ["Payment date date is in the future"]
          expect(StateBenefitPayment.count).to eq 0
        end
      end

      context "with missing parameter date" do
        let(:state_benefits_params) do
          {
            state_benefits: [
              {
                name: state_benefit_type1.label,
                payments: [
                  { amount: 266.95, client_id: "abc123" },
                ],
              },
            ],
          }
        end

        it "returns an error" do
          expect(creator.errors).to match [/The property '#\/state_benefits\/0\/payments\/0' did not contain a required property of 'date' in schema file/]
          expect(StateBenefitPayment.count).to eq 0
        end
      end

      def state_benefits_params
        {
          state_benefits: [
            {
              name: state_benefit_type1.label,
              payments: [
                { date: "2019-12-09", amount: 266.95, client_id: "abc123" },
                { date: "2019-11-09", amount: 584.31, client_id: "abc123" },
              ],
            },
            {
              name: state_benefit_type2.label,
              payments: [
                { date: "2019-12-06", amount: 193.47, client_id: "abc123" },
                { date: "2019-11-06", amount: 506.78, client_id: "abc123" },
              ],
            },
            {
              name: state_benefit_type3.label,
              payments: [
                { date: "2019-12-01", amount: 299.38, client_id: "abc123" },
                { date: "2019-11-01", amount: 810.38, client_id: "abc123" },
              ],
            },
          ],
        }
      end
    end
  end
end
