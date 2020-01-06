require 'rails_helper'

module Assessors
  RSpec.describe PropertyAssessor do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.capital_summary }
    let(:service) { PropertyAssessor.new(assessment) }

    describe '#call' do
      context 'no properties' do
        it 'does not create any property records' do
          expect(capital_summary.properties).to be_empty
          expect {
            service.call
          }.not_to change { capital_summary.properties.count }
        end
      end

      context 'main_home_only' do
        context '100% owned' do
          context 'with mortgage > £100,000' do
            let!(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     capital_summary: capital_summary,
                     value: 466_993,
                     outstanding_mortgage: 266_000,
                     percentage_owned: 100.0
            end
            it 'only deducts first 100k of mortgage' do
              service.call
              main_home.reload
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.allowable_outstanding_mortgage).to eq 100_000.0
              expect(main_home.net_value).to eq 352_983.21 # 466,993 - 14,009.79 - 100,000
              expect(main_home.net_equity).to eq 352_983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 252_983.21
            end
          end

          context 'with_mortgage less than 100k' do
            let!(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     capital_summary: capital_summary,
                     value: 466_993,
                     outstanding_mortgage: 37_256.44,
                     percentage_owned: 100.0
            end
            it 'only deducts the actual outstanding amount' do
              service.call
              main_home.reload
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.allowable_outstanding_mortgage).to eq 37_256.44
              expect(main_home.net_value).to eq 415_726.77 # 466,993 - 14,009.79 - 37,256.45
              expect(main_home.net_equity).to eq 415_726.77
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 315_726.77
            end
          end
        end

        context '66.66% owned' do
          context 'with mortgage > £100,000' do
            let!(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     capital_summary: capital_summary,
                     value: 466_993,
                     outstanding_mortgage: 266_000.44,
                     percentage_owned: 66.66
            end
            it 'only deducts first 100k of mortgage' do
              service.call
              main_home.reload
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.allowable_outstanding_mortgage).to eq 100_000.0
              expect(main_home.net_value).to eq 352_983.21 # 466,993 - 14,009.79 - 100,000
              expect(main_home.net_equity).to eq 235_298.61 # 66% of 352,983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 135_298.61
            end
          end

          context 'with mortgage < £100,000' do
            let!(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     capital_summary: capital_summary,
                     value: 466_993,
                     outstanding_mortgage: 37_256.44,
                     percentage_owned: 66.66
            end
            it 'only deducts the actual outstanding amount' do
              service.call
              main_home.reload
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.allowable_outstanding_mortgage).to eq 37_256.44
              expect(main_home.net_value).to eq 415_726.77 # 466,993 - 14,009.79 - 37,256.45
              expect(main_home.net_equity).to eq 277_123.46 # 66% of 415_726.77
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 177_123.46
            end
          end
        end

        context '50% shared with housing association' do
          let!(:main_home) do
            create :property,
                   :main_home,
                   :shared_ownership,
                   capital_summary: capital_summary,
                   value: 160_000,
                   outstanding_mortgage: 70_000,
                   percentage_owned: 50.0
          end
          it 'subtracts the housing association share as a %age of market value' do
            service.call
            main_home.reload
            expect(main_home.transaction_allowance).to eq 4_800.0 # 3% of 160,000
            expect(main_home.allowable_outstanding_mortgage).to eq 70_000.0
            expect(main_home.net_value).to eq 85_200.0 # 160,000 - 4,800 - 70,000
            expect(main_home.net_equity).to eq 5_200.0 # 85,200.0 - (50% of 160,000)
            expect(main_home.main_home_equity_disregard).to eq 100_000.0
            expect(main_home.assessed_equity).to eq 0
          end
        end
      end

      context 'additional_properties and main dwelling' do
        let!(:main_home) do
          create :property,
                 :main_home,
                 :not_shared_ownership,
                 capital_summary: capital_summary,
                 value: 220_000,
                 outstanding_mortgage: 35_000,
                 percentage_owned: 100.0
        end

        let!(:ap1) do
          create :property,
                 :additional_property,
                 :not_shared_ownership,
                 capital_summary: capital_summary,
                 value: 350_000,
                 outstanding_mortgage: 55_000,
                 percentage_owned: 100.0
        end

        let!(:ap2) do
          create :property,
                 :additional_property,
                 :not_shared_ownership,
                 capital_summary: capital_summary,
                 value: 270_000,
                 outstanding_mortgage: 40_000,
                 percentage_owned: 100.0
        end

        context 'main dwelling wholly owned and additional properties wholly owned' do
          it 'deducts a maximum of £100k mortgage over all properties' do
            service.call
            ap1.reload
            expect(ap1.transaction_allowance).to eq 10_500.0
            expect(ap1.allowable_outstanding_mortgage).to eq 55_000.0
            expect(ap1.net_value).to eq 284_500.0
            expect(ap1.net_equity).to eq 284_500.0
            expect(ap1.main_home_equity_disregard).to eq 0.0
            expect(ap1.assessed_equity).to eq 284_500.0

            ap2.reload
            expect(ap2.transaction_allowance).to eq 8_100.0
            expect(ap2.allowable_outstanding_mortgage).to eq 40_000.0
            expect(ap2.net_value).to eq 221_900.0
            expect(ap2.net_equity).to eq 221_900.0
            expect(ap2.main_home_equity_disregard).to eq 0.0
            expect(ap2.assessed_equity).to eq 221_900.0

            main_home.reload
            expect(main_home.transaction_allowance).to eq 6_600.0
            expect(main_home.allowable_outstanding_mortgage).to eq 5_000.0
            expect(main_home.net_value).to eq 208_400.0
            expect(main_home.net_equity).to eq 208_400.0
            expect(main_home.main_home_equity_disregard).to eq 100_000.0
            expect(main_home.assessed_equity).to eq 108_400.0
          end
        end
      end

      context 'additional property but no main dwelling' do
        let!(:additional_property) do
          create :property,
                 :additional_property,
                 :not_shared_ownership,
                 capital_summary: capital_summary,
                 value: 350_000,
                 outstanding_mortgage: 55_000,
                 percentage_owned: 100.0
        end

        it 'calculates the additional property correctly' do
          service.call
          additional_property.reload
          expect(additional_property.transaction_allowance).to eq 10_500.0
          expect(additional_property.allowable_outstanding_mortgage).to eq 55_000.0
          expect(additional_property.net_value).to eq 284_500.0
          expect(additional_property.net_equity).to eq 284_500.0
          expect(additional_property.main_home_equity_disregard).to eq 0.0
          expect(additional_property.assessed_equity).to eq 284_500.0
          expect(capital_summary.main_home).to be_nil
        end
      end
    end
  end
end
