require 'rails_helper'

module Calculators
  RSpec.describe HousingCostsCalculator do
    let(:assessment) { create :assessment, :with_gross_income_summary_and_records, :with_disposable_income_summary, with_child_dependants: children }
    let(:rent_or_mortgage_category) { assessment.cash_transaction_categories.detect { |cat| cat.name == 'rent_or_mortgage' } }
    let(:rent_or_mortgage_transactions) { rent_or_mortgage_category.cash_transactions.order(:date) }
    let(:monthly_cash_housing) { rent_or_mortgage_transactions.average(:amount).round(2).to_d }
    let(:children) { 0 }

    subject(:calculator) { described_class.new(assessment) }

    before do
      create :bank_holiday
      [2.months.ago, 1.month.ago, Date.current].each do |date|
        create :housing_cost_outgoing,
               disposable_income_summary: assessment.disposable_income_summary,
               payment_date: date,
               amount: housing_cost_amount,
               housing_cost_type: housing_cost_type
      end

      subject
      assessment.disposable_income_summary.reload
      @assessment = assessment
    end

    context 'when applicant has no dependants' do
      let(:housing_cost_amount) { 1200.00 }

      context 'and does not receive housing benefit' do
        context 'board and lodging' do
          let(:housing_cost_type) { 'board_and_lodging' }
          let(:housing_cost_amount) { 1500.00 }

          it 'should cap the return' do
            expect(calculator.gross_housing_costs).to eq 750.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 0.0
            expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
          end

          context 'when 50% of monthly bank outgoings are below the cap but overall above it when including cash payments' do
            let(:housing_cost_amount) { 1088.00 }

            it 'should return the gross cost as net' do
              expect(calculator.gross_housing_costs).to eq 544.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end
          end

          context 'when 50% of monthly bank and cash outgoings are below the cap' do
            let(:housing_cost_amount) { 888.0 }

            it 'should return the gross cost as net' do
              expect(calculator.gross_housing_costs).to eq 444.0.to_d + monthly_cash_housing.to_d
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 444.0.to_d + monthly_cash_housing.to_d
            end
          end
        end

        context 'rent' do
          let(:housing_cost_type) { 'rent' }

          it 'should cap the return' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 0.0
            expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 420.00 }

            it 'should return the net cost' do
              expect(calculator.gross_housing_costs).to eq 420.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 420.00 + monthly_cash_housing
            end
          end
        end

        context 'mortgage' do
          let(:housing_cost_type) { 'mortgage' }

          it 'should cap the return' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 0.0
            expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 420.00 }

            it 'should return the net cost' do
              expect(calculator.gross_housing_costs).to eq 420.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 420.00.to_d + monthly_cash_housing
            end
          end
        end
      end

      context 'and receives housing benefit' do
        let(:housing_benefit_amount) { 500.00 }
        before { create_benefit_payments(housing_benefit_amount) }

        context 'and pays board and lodging' do
          let(:housing_cost_type) { 'board_and_lodging' }
          let(:housing_cost_amount) { 1500.00 }
          let(:housing_benefit_amount) { 100.00 }

          it 'should cap the return' do
            expect(calculator.gross_housing_costs).to eq 750.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 100.00
            expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
          end
        end

        context 'rent' do
          let(:housing_cost_type) { 'rent' }

          it 'should cap the return' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 500.0
            expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
          end

          context 'when net amount will be below the cap' do
            let(:housing_cost_amount) { 1200.00 }
            let(:housing_benefit_amount) { 500.00 }

            it 'should cap the return' do
              expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 500.0
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end
          end
        end

        context 'mortgage' do
          let(:housing_cost_type) { 'mortgage' }

          it 'should cap the return' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 500.00
            expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
          end

          context 'when net amount will be below the cap' do
            let(:housing_cost_amount) { 600.00 }
            let(:housing_benefit_amount) { 200.00 }

            it 'should return net as gross_cost minus housing_benefit' do
              expect(calculator.gross_housing_costs).to eq 600.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 200.0
              expect(calculator.net_housing_costs).to eq 400.00.to_d + monthly_cash_housing
            end
          end
        end
      end
    end

    context 'when applicant has dependants' do
      let(:housing_cost_amount) { 1200.00 }
      let(:children) { 1 }

      context 'no housing benefit' do
        context 'board and lodging' do
          let(:housing_cost_type) { 'board_and_lodging' }
          let(:housing_cost_amount) { 1500.00 }

          it 'should record half the monthly housing cost' do
            expect(calculator.gross_housing_costs).to eq 750.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 0.0
            expect(calculator.net_housing_costs).to eq 750.00.to_d + monthly_cash_housing
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 900.00 }

            it 'should return half the monthly housing cost' do
              expect(calculator.gross_housing_costs).to eq 450.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 450.00.to_d + monthly_cash_housing
            end
          end
        end

        context 'rent' do
          let(:housing_cost_type) { 'rent' }

          it 'should record the full monthly housing costs' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 0.0
            expect(calculator.net_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 520.00 }

            it 'should return the net cost' do
              expect(calculator.gross_housing_costs).to eq 520.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 520.00.to_d + monthly_cash_housing
            end
          end
        end

        context 'mortgage' do
          let(:housing_cost_type) { 'mortgage' }
          it 'should record the full monthly housing costs' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 0.0
            expect(calculator.net_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 520.00 }

            it 'should return the gross cost as net' do
              expect(calculator.gross_housing_costs).to eq 520.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 520.00.to_d + monthly_cash_housing
            end
          end
        end
      end

      context 'housing benefit' do
        let(:housing_benefit_amount) { 500.00 }
        before { create_benefit_payments(housing_benefit_amount) }

        context 'board and lodging' do
          let(:housing_cost_type) { 'board_and_lodging' }
          let(:housing_cost_amount) { 1200.00 }
          let(:housing_benefit_amount) { 100.00 }

          it 'should record half the monthly outgoing less the housing benefit' do
            expect(calculator.gross_housing_costs).to eq 600.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 100.000
            expect(calculator.net_housing_costs).to eq((housing_cost_amount.to_d + monthly_cash_housing - housing_benefit_amount.to_d) / 2)
          end
        end

        context 'board and lodging different values' do
          let(:housing_cost_type) { 'board_and_lodging' }
          let(:housing_cost_amount) { 1500.00 }
          let(:housing_benefit_amount) { 100.00 }

          it 'should record half the housing cost less the housing benefit' do
            expect(calculator.gross_housing_costs).to eq 750.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 100.00
            expect(calculator.net_housing_costs).to eq((housing_cost_amount.to_d + monthly_cash_housing - housing_benefit_amount.to_d) / 2)
          end
        end

        context 'rent' do
          let(:housing_cost_type) { 'rent' }

          it 'should record the full monthly housing costs' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 500.00
            expect(calculator.net_housing_costs).to eq 700.00.to_d + monthly_cash_housing
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 600.00 }
            let(:housing_benefit_amount) { 200.00 }

            it 'should return net as gross_cost minus housing_benefit' do
              expect(calculator.gross_housing_costs).to eq 600.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 200.0
              expect(calculator.net_housing_costs).to eq 400.00.to_d + monthly_cash_housing
            end
          end
        end

        context 'mortgage' do
          let(:housing_cost_type) { 'mortgage' }

          it 'should record the full housing costs less the housing benefit' do
            expect(calculator.gross_housing_costs).to eq 1200.00.to_d + monthly_cash_housing
            expect(calculator.monthly_housing_benefit).to eq 500.00
            expect(calculator.net_housing_costs).to eq 700.00.to_d + monthly_cash_housing
          end

          context 'when net cost is below housing cap' do
            let(:housing_cost_amount) { 600.00 }
            let(:housing_benefit_amount) { 200.00 }

            it 'should return net as gross_cost minus housing_benefit' do
              expect(calculator.gross_housing_costs).to eq 600.00.to_d + monthly_cash_housing
              expect(calculator.monthly_housing_benefit).to eq 200.0
              expect(calculator.net_housing_costs).to eq 400.00.to_d + monthly_cash_housing
            end
          end
        end
      end
    end

    def create_benefit_payments(amount)
      housing_benefit_type = create :state_benefit_type, label: 'housing_benefit'
      state_benefit = create :state_benefit, gross_income_summary: assessment.gross_income_summary, state_benefit_type: housing_benefit_type
      [2.months.ago, 1.month.ago, Date.current].each do |pay_date|
        create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: pay_date
      end
    end
  end
end
