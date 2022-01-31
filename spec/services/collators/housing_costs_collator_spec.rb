require "rails_helper"

module Collators
  RSpec.describe HousingCostsCollator do
    before { create :bank_holiday }

    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }

      subject { described_class.call(assessment) }

      context "no housing cost outgoings" do
        it "records zero" do
          subject
          expect(disposable_income_summary.gross_housing_costs).to eq 0.0
          expect(disposable_income_summary.housing_benefit).to eq 0.0
          expect(disposable_income_summary.net_housing_costs).to eq 0.0
        end
      end

      context "housing cost outgoings" do
        before do
          create :housing_cost_outgoing, disposable_income_summary: disposable_income_summary, amount: 355.44, payment_date: Date.current, housing_cost_type: housing_cost_type
          create :housing_cost_outgoing, disposable_income_summary: disposable_income_summary, amount: 355.44, payment_date: 1.month.ago, housing_cost_type: housing_cost_type
          create :housing_cost_outgoing, disposable_income_summary: disposable_income_summary, amount: 355.44, payment_date: 2.months.ago, housing_cost_type: housing_cost_type
        end

        context "no housing benefit" do
          context "board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the monthly housing cost" do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 177.72
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 177.72
            end
          end

          context "rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 355.44
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 355.44
            end
          end
        end

        context "housing benefit" do
          before do
            housing_benefit_type = create :state_benefit_type, label: "housing_benefit"
            state_benefit = create :state_benefit, gross_income_summary: gross_income_summary, state_benefit_type: housing_benefit_type
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: Date.current
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: 1.month.ago
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: 2.months.ago
          end

          context "board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the housing cost less the housing benefit" do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 177.72
              expect(disposable_income_summary.housing_benefit).to eq 101.02
              expect(disposable_income_summary.net_housing_costs).to eq 76.70 # 177.72 - 101.02
            end
          end

          context "mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full housing costs less the housing benefit" do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 355.44
              expect(disposable_income_summary.housing_benefit).to eq 101.02
              expect(disposable_income_summary.net_housing_costs).to eq 254.42 # 355.44 - 101.02
            end
          end
        end
      end
    end
  end
end
