require "rails_helper"

module Collators
  RSpec.describe HousingCostsCollator do
    before { create :bank_holiday }

    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }

      subject(:collator) do
        described_class.call(disposable_income_summary: assessment.disposable_income_summary,
                             person: OpenStruct.new(single?: true, dependants: assessment.dependants),
                             gross_income_summary: assessment.gross_income_summary,
                             submission_date: assessment.submission_date,
                             allow_negative_net: false)
      end

      context "with no housing cost outgoings" do
        context "without housing benefit" do
          it "has expected housing cost attributes" do
            collator
            expect(disposable_income_summary)
              .to have_attributes(
                gross_housing_costs: 0.0,
                housing_benefit: 0.0,
                net_housing_costs: 0.0,
              )
          end
        end

        context "with housing benefit as a state_benefit" do
          before do
            housing_benefit_type = create :state_benefit_type, label: "housing_benefit"
            state_benefit = create :state_benefit, gross_income_summary: gross_income_summary, state_benefit_type: housing_benefit_type
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: Date.current
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: 1.month.ago
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: 2.months.ago
          end

          it "has expected housing cost attributes" do
            collator
            expect(disposable_income_summary)
              .to have_attributes(
                gross_housing_costs: 0.0,
                housing_benefit: 101.02,
                net_housing_costs: 0,
              )
          end
        end
      end

      context "with housing cost outgoings" do
        before do
          create :housing_cost_outgoing, disposable_income_summary: disposable_income_summary, amount: 355.44, payment_date: Date.current, housing_cost_type: housing_cost_type
          create :housing_cost_outgoing, disposable_income_summary: disposable_income_summary, amount: 355.44, payment_date: 1.month.ago, housing_cost_type: housing_cost_type
          create :housing_cost_outgoing, disposable_income_summary:, amount: 355.44, payment_date: 2.months.ago, housing_cost_type:
        end

        context "without housing benefit" do
          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the monthly housing cost" do
              collator
              expect(disposable_income_summary)
                .to have_attributes(
                  gross_housing_costs: 177.72,
                  housing_benefit: 0.0,
                  net_housing_costs: 177.72,
                )
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              collator
              expect(disposable_income_summary)
                .to have_attributes(
                  gross_housing_costs: 355.44,
                  housing_benefit: 0.0,
                  net_housing_costs: 355.44,
                )
            end
          end
        end

        context "with housing benefit as a state_benefit" do
          before do
            housing_benefit_type = create :state_benefit_type, label: "housing_benefit"
            state_benefit = create :state_benefit, gross_income_summary: gross_income_summary, state_benefit_type: housing_benefit_type
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: Date.current
            create :state_benefit_payment, state_benefit: state_benefit, amount: 101.02, payment_date: 1.month.ago
            create :state_benefit_payment, state_benefit:, amount: 101.02, payment_date: 2.months.ago
          end

          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }

            it "records half the housing cost less the housing benefit" do
              collator
              expect(disposable_income_summary)
                .to have_attributes(
                  gross_housing_costs: 177.72,
                  housing_benefit: 101.02,
                  net_housing_costs: 76.70, # 177.72 - 101.02
                )
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full housing costs less the housing benefit" do
              collator
              expect(disposable_income_summary)
                .to have_attributes(
                  gross_housing_costs: 355.44,
                  housing_benefit: 101.02,
                  net_housing_costs: 254.42, # 355.44 - 101.02
                )
            end
          end
        end
      end

      context "with housing cost regular_transactions" do
        before do
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "three_monthly", amount: 1000.00)
        end

        context "without housing benefit" do
          it "records the full monthly housing costs" do
            collator
            expect(disposable_income_summary)
              .to have_attributes(
                gross_housing_costs: 333.33,
                housing_benefit: 0.0,
                net_housing_costs: 333.33,
              )
          end
        end

        context "with housing benefit as a regular_transaction" do
          before do
            create(:regular_transaction, gross_income_summary:, operation: "credit", category: "housing_benefit", frequency: "three_monthly", amount: 1000.0)
          end

          it "records half the housing cost less the housing benefit" do
            collator
            expect(disposable_income_summary)
              .to have_attributes(
                gross_housing_costs: 333.33,
                housing_benefit: 333.33,
                net_housing_costs: 0.00,
              )
          end
        end
      end
    end
  end
end
