require "rails_helper"

module Calculators
  RSpec.describe HousingCostsCalculator do
    subject(:calculator) do
      described_class.new(disposable_income_summary: assessment.disposable_income_summary,
                          dependants: assessment.dependants,
                          submission_date: assessment.submission_date,
                          gross_income_summary: assessment.gross_income_summary)
    end

    context "when using outgoings and state_benefits" do
      let(:assessment) { create :assessment, :with_gross_income_summary_and_records, :with_disposable_income_summary, with_child_dependants: children }
      let(:rent_or_mortgage_category) { assessment.cash_transaction_categories.detect { |cat| cat.name == "rent_or_mortgage" } }
      let(:rent_or_mortgage_transactions) { rent_or_mortgage_category.cash_transactions.order(:date) }
      let(:monthly_cash_housing) { rent_or_mortgage_transactions.average(:amount).round(2).to_d }
      let(:children) { 0 }

      before do
        stub_request(:get, "https://www.gov.uk/bank-holidays.json")
          .to_return(body: file_fixture("bank-holidays.json").read)

        [2.months.ago, 1.month.ago, Date.current].each do |date|
          create :housing_cost_outgoing,
                 disposable_income_summary: assessment.disposable_income_summary,
                 payment_date: date,
                 amount: housing_cost_amount,
                 housing_cost_type:
        end

        calculator
        assessment.disposable_income_summary.reload
        @assessment = assessment
      end

      context "when applicant has no dependants" do
        let(:housing_cost_amount) { 1200.00 }

        context "and does not receive housing benefit" do
          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1500.00 }

            it "caps the return" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("750.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end

            context "when 50% of monthly bank outgoings are below the cap but overall above it when including cash payments" do
              let(:housing_cost_amount) { 1088.00 }

              it "returns the gross cost as net" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("544.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
              end
            end

            context "when 50% of monthly bank and cash outgoings are below the cap" do
              let(:housing_cost_amount) { 888.0 }

              it "returns the gross cost as net" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("444.0") + monthly_cash_housing # all variables are always decimals
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq (BigDecimal("444.0") + monthly_cash_housing).to_f # net_housing_costs is always a float
              end
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "caps the return" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 420.00 }

              it "returns the net cost" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("420.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq 420.00 + monthly_cash_housing
              end
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "caps the return" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 420.00 }

              it "returns the net cost" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("420.00") + monthly_cash_housing # all variables are always decimals
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq (BigDecimal("420.00") + monthly_cash_housing).to_f # net_housing_costs is always a float
              end
            end
          end
        end

        context "and receives housing benefit as a state_benefit" do
          let(:housing_benefit_amount) { 500.00 }

          before { create_housing_benefit_payments(housing_benefit_amount) }

          context "with board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1500.00 }
            let(:housing_benefit_amount) { 100.00 }

            it "caps the return" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("750.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 100.00
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end
          end

          context "with rent" do
            let(:housing_cost_type) { "rent" }

            it "caps the return" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 500.0
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 1000.00 }
              let(:housing_benefit_amount) { 600.00 }

              it "returns gross less housing benefits" do
                expect(calculator.gross_housing_costs).to eq 1000.00 + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 600.0
                expect(calculator.net_housing_costs).to eq 400.00 + monthly_cash_housing
              end
            end
          end

          context "with mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "caps the return" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 500.00
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end

            context "when net amount will be below the cap" do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it "returns net as gross_cost minus housing_benefit" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("600.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 200.0
                expect(calculator.net_housing_costs).to eq BigDecimal("400.00") + monthly_cash_housing
              end
            end
          end
        end
      end

      context "when applicant has dependants" do
        let(:housing_cost_amount) { 1200.00 }
        let(:children) { 1 }

        context "with no housing benefit" do
          context "board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1500.00 }

            it "records half the monthly housing cost" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("750.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq BigDecimal("750.00") + monthly_cash_housing
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 900.00 }

              it "returns half the monthly housing cost" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("450.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq BigDecimal("450.00") + monthly_cash_housing
              end
            end
          end

          context "rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 520.00 }

              it "returns the net cost" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("520.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq BigDecimal("520.00") + monthly_cash_housing
              end
            end
          end

          context "mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full monthly housing costs" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 520.00 }

              it "returns the gross cost as net" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("520.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 0.0
                expect(calculator.net_housing_costs).to eq BigDecimal("520.00") + monthly_cash_housing
              end
            end
          end
        end

        context "with housing benefit as a state_benefit" do
          let(:housing_benefit_amount) { 500.00 }

          before { create_housing_benefit_payments(housing_benefit_amount) }

          context "board and lodging" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1200.00 }
            let(:housing_benefit_amount) { 100.00 }

            it "records half the monthly outgoing less the housing benefit" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("600.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 100.000
              expect(calculator.net_housing_costs).to eq((housing_cost_amount.to_d + monthly_cash_housing - housing_benefit_amount.to_d) / 2)
            end
          end

          context "board and lodging different values" do
            let(:housing_cost_type) { "board_and_lodging" }
            let(:housing_cost_amount) { 1500.00 }
            let(:housing_benefit_amount) { 100.00 }

            it "records half the housing cost less the housing benefit" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("750.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 100.00
              expect(calculator.net_housing_costs).to eq((housing_cost_amount.to_d + monthly_cash_housing - housing_benefit_amount.to_d) / 2)
            end
          end

          context "rent" do
            let(:housing_cost_type) { "rent" }

            it "records the full monthly housing costs" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 500.00
              expect(calculator.net_housing_costs).to eq BigDecimal("700.00") + monthly_cash_housing
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it "returns net as gross_cost minus housing_benefit" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("600.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 200.0
                expect(calculator.net_housing_costs).to eq BigDecimal("400.00") + monthly_cash_housing
              end
            end
          end

          context "mortgage" do
            let(:housing_cost_type) { "mortgage" }

            it "records the full housing costs less the housing benefit" do
              expect(calculator.gross_housing_costs).to eq BigDecimal("1200.00") + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 500.00
              expect(calculator.net_housing_costs).to eq BigDecimal("700.00") + monthly_cash_housing
            end

            context "when net cost is below housing cap" do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it "returns net as gross_cost minus housing_benefit" do
                expect(calculator.gross_housing_costs).to eq BigDecimal("600.00") + monthly_cash_housing
                expect(calculator.monthly_housing_benefit).to eq 200.0
                expect(calculator.net_housing_costs).to eq BigDecimal("400.00") + monthly_cash_housing
              end
            end
          end
        end
      end
    end

    context "when using regular_transactions" do
      let(:instance) do
        described_class.new(disposable_income_summary: assessment.disposable_income_summary,
                            gross_income_summary: assessment.gross_income_summary,
                            submission_date: assessment.submission_date,
                            dependants: assessment.dependants)
      end
      let(:assessment) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary }
      let(:dates) { [Date.current, 1.month.ago, 2.months.ago] }

      before do
        stub_request(:get, "https://www.gov.uk/bank-holidays.json")
          .to_return(body: file_fixture("bank-holidays.json").read)
      end

      describe "#gross_housing_costs" do
        subject(:gross_housing_costs) { instance.gross_housing_costs }

        context "with no housing costs" do
          it { is_expected.to eq 0 }
        end

        context "with all forms of housing costs" do
          before do
            # add monthly equivalent bank transactions of 111.11
            create(:housing_cost_outgoing, disposable_income_summary: assessment.disposable_income_summary, payment_date: dates[0], amount: 333.33)

            # add average cash transactions of 111.11
            rent_or_mortgage = create(:cash_transaction_category, name: "rent_or_mortgage", operation: "debit", gross_income_summary: assessment.gross_income_summary)
            create(:cash_transaction, cash_transaction_category: rent_or_mortgage, date: dates[0], amount: 111.11)
            create(:cash_transaction, cash_transaction_category: rent_or_mortgage, date: dates[1], amount: 111.11)
            create(:cash_transaction, cash_transaction_category: rent_or_mortgage, date: dates[2], amount: 111.11)

            # add monthly equivalent regular transaction of 333.33
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "debit", category: "rent_or_mortgage", frequency: "three_monthly", amount: 1000.00)
          end

          # NOTE: expected API use cases should not add both bank and regular transactions
          it "sums monthly bank, regular and cash transactions" do
            expect(gross_housing_costs).to eq 555.55 # 111.11 + 111.11 + 333.33
          end
        end
      end

      describe "#monthly_housing_benefit" do
        subject(:monthly_housing_benefit) { instance.monthly_housing_benefit }

        context "with state_benefits of housing_benefit type" do
          before do
            housing_benefit = create(:state_benefit,
                                     gross_income_summary: assessment.gross_income_summary,
                                     state_benefit_type: build(:state_benefit_type, label: "housing_benefit"))

            create(:state_benefit_payment, state_benefit: housing_benefit, amount: 222.22, payment_date: dates[0])
            create(:state_benefit_payment, state_benefit: housing_benefit, amount: 222.22, payment_date: dates[2])
          end

          it "returns monthly equivalent" do
            expect(monthly_housing_benefit).to eq 148.15 # (222.22 + 222.22) / 3
          end
        end

        context "with regular_transactions of housing_benefit type" do
          before do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "three_monthly", amount: 1000.00)
          end

          it "returns monthly equivalent" do
            expect(monthly_housing_benefit).to eq 333.33 # 1000.00 / 3
          end
        end
      end

      describe "#net_housing_costs" do
        subject(:net_housing_costs) { instance.net_housing_costs }

        context "when single, with no dependants" do
          it "returns gross housing cost less benefits" do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 1000.00)
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "monthly", amount: 500.00)

            expect(net_housing_costs).to eq 500.00
          end

          it "implements a cap" do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 1000.00)
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "monthly", amount: 400.00)

            expect(net_housing_costs).to eq 545.00
          end

          it "has zero floor" do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "monthly", amount: 400.00)

            expect(net_housing_costs).to eq 0.00
          end
        end

        context "when has dependants and receives housing benefit" do
          before do
            create(:dependant, :child_relative, assessment:)
          end

          it "returns gross housing cost less benefits" do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 1000.00)
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "monthly", amount: 500.00)

            expect(net_housing_costs).to eq 500.00
          end

          it "has zero floor" do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "monthly", amount: 400.00)

            expect(net_housing_costs).to eq 0.00
          end
        end

        # NOTE: when has dependants without benefits
        # or when not single and with no dependants??
        #
        context "when any other situation" do
          before do
            create(:dependant, :child_relative, assessment:)
          end

          it "returns gross housing without a cap" do
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 1000.00)
            create(:regular_transaction, gross_income_summary: assessment.gross_income_summary, operation: "credit", category: "housing_benefit", frequency: "monthly", amount: 400.00)

            expect(net_housing_costs).to eq 600.00
          end
        end
      end
    end

    def create_housing_benefit_payments(amount)
      housing_benefit_type = create :state_benefit_type, label: "housing_benefit"
      state_benefit = create :state_benefit, gross_income_summary: assessment.gross_income_summary, state_benefit_type: housing_benefit_type
      [2.months.ago, 1.month.ago, Date.current].each do |pay_date|
        create :state_benefit_payment, state_benefit:, amount:, payment_date: pay_date
      end
    end
  end
end
