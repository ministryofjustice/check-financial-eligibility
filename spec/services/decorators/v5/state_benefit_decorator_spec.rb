require "rails_helper"

module Decorators
  module V5
    RSpec.describe StateBenefitDecorator do
      describe "#as_json" do
        before { create :disposable_income_summary, :with_everything, assessment: gross_income_summary.assessment }

        let(:state_benefit) { create :state_benefit, :with_monthly_payments, name: "Childcare allowance" }
        let(:excluded) { state_benefit.state_benefit_type.exclude_from_gross_income }
        let!(:gross_income_summary) { create :gross_income_summary }

        subject(:decorator) { described_class.new(state_benefit).as_json }

        it "returns the expected hash" do
          expected_hash = {
            name: "Childcare allowance",
            monthly_value: 88.3,
            excluded_from_income_assessment: excluded,
          }
          expect(decorator).to eq expected_hash
        end
      end
    end
  end
end
