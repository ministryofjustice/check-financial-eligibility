require "rails_helper"

module Decorators
  module V5
    RSpec.describe DisposableIncomeSummaryDecorator do
      describe "#as_json" do
        subject(:decorator) { described_class.new(disposable_income_summary).as_json }

        context "disposable income summary is nil" do
          let(:disposable_income_summary) { nil }

          it "returns nil" do
            expect(decorator).to be_nil
          end
        end

        context "disposable income summary exists" do
          before do
            create :gross_income_summary, assessment: disposable_income_summary.assessment
            create :disposable_income_eligibility, disposable_income_summary:
          end

          let(:assessment) { create :assessment, proceedings: [%w[DA003 A]] }
          let(:disposable_income_summary) { create :disposable_income_summary, :with_everything, :with_eligibilities, assessment: }

          it "has the expected keys in the response structure" do
            expected_keys = %i[
              monthly_equivalents
              childcare_allowance
              deductions
              dependant_allowance
              maintenance_allowance
              gross_housing_costs
              housing_benefit
              net_housing_costs
              total_outgoings_and_allowances
              total_disposable_income
              lower_threshold
              upper_threshold
              assessment_result
              income_contribution
            ]
            expect(decorator.keys).to eq expected_keys
            expect(decorator[:monthly_equivalents].keys).to eq %i[bank_transactions cash_transactions all_sources]
          end

          it "has transaction types which contain all transaction categories" do
            outgoings_keys = CFEConstants::VALID_OUTGOING_CATEGORIES.map(&:to_sym)
            expect(decorator[:monthly_equivalents][:bank_transactions].keys).to eq outgoings_keys
            expect(decorator[:monthly_equivalents][:cash_transactions].keys).to eq outgoings_keys
            expect(decorator[:monthly_equivalents][:all_sources].keys).to eq outgoings_keys
          end
        end
      end
    end
  end
end
