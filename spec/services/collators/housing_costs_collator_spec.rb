require 'rails_helper'

module Collators
  RSpec.describe HousingCostsCollator do
    describe '.call' do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary, with_child_dependants: children }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:children) { 0 }

      subject { described_class.call(assessment) }

      context 'no housing cost outgoings' do
        it 'should record zero' do
          subject
          expect(disposable_income_summary.gross_housing_costs).to eq 0.0
          expect(disposable_income_summary.housing_benefit).to eq 0.0
          expect(disposable_income_summary.net_housing_costs).to eq 0.0
        end
      end

      context 'when applicant has no dependants' do
        let(:housing_cost_amount) { 1200.00 }
        before { create_housing_costs(housing_cost_amount) }

        context 'no housing benefit' do
          context 'board and lodging' do
            let(:housing_cost_type) { 'board_and_lodging' }
            let(:housing_cost_amount) { 1500.00 }

            it 'should cap the return' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 750.00
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
            end

            context 'when 50% of monthly outgoing is below the cap' do
              let(:housing_cost_amount) { 1040.00 }

              it 'should return the gross cost as net' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 520.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 520.00
              end
            end
          end

          context 'rent' do
            let(:housing_cost_type) { 'rent' }

            it 'should cap the return' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 520.00 }

              it 'should return the net cost' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 520.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 520.00
              end
            end
          end

          context 'mortgage' do
            let(:housing_cost_type) { 'mortgage' }

            it 'should cap the return' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 520.00 }

              it 'should return the net cost' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 520.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 520.00
              end
            end
          end
        end

        context 'housing benefit' do
          let(:housing_benefit_amount) { 500.00 }
          before { create_benefit_payments(housing_benefit_amount) }

          context 'board and lodging' do
            let(:housing_cost_type) { 'board_and_lodging' }
            let(:housing_cost_amount) { 1500.00 }
            let(:housing_benefit_amount) { 100.00 }

            it 'should cap the return' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 750.00
              expect(disposable_income_summary.housing_benefit).to eq 100.00
              expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
            end
          end

          context 'rent' do
            let(:housing_cost_type) { 'rent' }

            it 'should cap the return' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 500.0
              expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
            end

            context 'when net amount will be below the cap' do
              let(:housing_cost_amount) { 1200.00 }
              let(:housing_benefit_amount) { 500.00 }

              it 'should cap the return' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
                expect(disposable_income_summary.housing_benefit).to eq 500.0
                expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
              end
            end
          end

          context 'mortgage' do
            let(:housing_cost_type) { 'mortgage' }

            it 'should cap the return' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 500.00
              expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
            end

            context 'when net amount will be below the cap' do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it 'should return net as gross_cost minus housing_benefit' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 600.00
                expect(disposable_income_summary.housing_benefit).to eq 200.0
                expect(disposable_income_summary.net_housing_costs).to eq 400.00
              end
            end
          end
        end
      end

      context 'when applicant has dependants' do
        let(:housing_cost_amount) { 1200.00 }
        let(:children) { 1 }
        before { create_housing_costs(housing_cost_amount) }

        context 'no housing benefit' do
          context 'board and lodging' do
            let(:housing_cost_type) { 'board_and_lodging' }
            let(:housing_cost_amount) { 1500.00 }

            it 'should record half the monthly housing cost' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 750.00
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 750.00
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 900.00 }

              it 'should return half the monthly housing cost' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 450.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 450.00
              end
            end
          end

          context 'rent' do
            let(:housing_cost_type) { 'rent' }
            it 'should record the full monthly housing costs' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 1200.00
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 520.00 }

              it 'should return the net cost' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 520.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 520.00
              end
            end
          end

          context 'mortgage' do
            let(:housing_cost_type) { 'mortgage' }
            it 'should record the full monthly housing costs' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 0.0
              expect(disposable_income_summary.net_housing_costs).to eq 1200.00
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 520.00 }

              it 'should return the gross cost as net' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 520.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 520.00
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
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 600.00
              expect(disposable_income_summary.housing_benefit).to eq 100.000
              expect(disposable_income_summary.net_housing_costs).to eq 550.00
            end
          end

          context 'board and lodging different values' do
            let(:housing_cost_type) { 'board_and_lodging' }
            let(:housing_cost_amount) { 1500.00 }
            let(:housing_benefit_amount) { 100.00 }

            it 'should record half the housing cost less the housing benefit' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 750.00
              expect(disposable_income_summary.housing_benefit).to eq 100.00
              expect(disposable_income_summary.net_housing_costs).to eq 700.00
            end
          end

          context 'rent' do
            let(:housing_cost_type) { 'rent' }

            it 'should record the full monthly housing costs' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 500.0
              expect(disposable_income_summary.net_housing_costs).to eq 700.00
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it 'should return net as gross_cost minus housing_benefit' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 600.00
                expect(disposable_income_summary.housing_benefit).to eq 200.0
                expect(disposable_income_summary.net_housing_costs).to eq 400.00
              end
            end
          end

          context 'mortgage' do
            let(:housing_cost_type) { 'mortgage' }

            it 'should record the full housing costs less the housing benefit' do
              subject
              expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
              expect(disposable_income_summary.housing_benefit).to eq 500.00
              expect(disposable_income_summary.net_housing_costs).to eq 700.00
            end

            context 'when net cost is below housing cap' do
              let(:housing_cost_amount) { 600.00 }
              let(:housing_benefit_amount) { 200.00 }

              it 'should return net as gross_cost minus housing_benefit' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 600.00
                expect(disposable_income_summary.housing_benefit).to eq 200.0
                expect(disposable_income_summary.net_housing_costs).to eq 400.00
              end
            end
          end
        end
      end
    end

    def create_housing_costs(amount)
      [Date.today, 1.month.ago, 2.months.ago].each do |pay_date|
        create :housing_cost_outgoing,
               disposable_income_summary: disposable_income_summary,
               amount: amount,
               payment_date: pay_date,
               housing_cost_type: housing_cost_type
      end
    end

    def create_benefit_payments(amount)
      housing_benefit_type = create :state_benefit_type, label: 'housing_benefit'
      state_benefit = create :state_benefit, gross_income_summary: gross_income_summary, state_benefit_type: housing_benefit_type
      [Date.today, 1.month.ago, 2.months.ago].each do |pay_date|
        create :state_benefit_payment, state_benefit: state_benefit, amount: amount, payment_date: pay_date
      end
    end
  end
end
