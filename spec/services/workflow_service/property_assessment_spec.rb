require 'rails_helper'

module WorkflowService # rubocop:disable Metrics/ModuleLength
  RSpec.describe PropertyAssessment do
    let(:assessment) { create :assessment }
    let(:service) { PropertyAssessment.new(assessment) }

    describe '#call' do
      context 'no properties' do
        it 'returns nil' do
          result = service.call
          expect(result.main_home).to be_empty
          expect(result.additional_properties).to be_empty
        end
      end

      context 'main_home_only' do
        context '100% owned' do
          context 'with mortgage > £100,000' do
            let(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     value: 466_993,
                     outstanding_mortgage: 266_000,
                     percentage_owned: 100.0
            end
            it 'only deducts first 100k of mortgage' do
              assessment.properties << main_home
              main_home = service.call.main_home
              expect(main_home.notional_sale_costs_pctg).to eq 3.0
              expect(main_home.net_value_after_deduction).to eq 452_983.21
              expect(main_home.maximum_mortgage_allowance).to eq 100_000.0
              expect(main_home.net_value_after_mortgage).to eq 352_983.21
              expect(main_home.percentage_owned).to eq 100.0
              expect(main_home.net_equity_value).to eq 352_983.21
              expect(main_home.property_disregard).to eq 100_000.0
              expect(main_home.assessed_capital_value).to eq 252_983.21
            end
          end

          context 'with_mortgage less than 100k' do
            let(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     value: 466_993,
                     outstanding_mortgage: 37_256.44,
                     percentage_owned: 100.0
            end
            it 'only deducts the actual outstanding amount' do
              assessment.properties << main_home
              main_home = service.call.main_home
              expect(main_home.notional_sale_costs_pctg).to eq 3.0
              expect(main_home.net_value_after_deduction).to eq 452_983.21
              expect(main_home.maximum_mortgage_allowance).to eq 37_256.44
              expect(main_home.net_value_after_mortgage).to eq 415_726.77
              expect(main_home.percentage_owned).to eq 100.0
              expect(main_home.net_equity_value).to eq 415_726.77
              expect(main_home.property_disregard).to eq 100_000.0
              expect(main_home.assessed_capital_value).to eq 315_726.77
            end
          end
        end

        context '66.66% owned' do
          context 'with mortgage > £100,000' do
            let(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     value: 466_993,
                     outstanding_mortgage: 266_000.44,
                     percentage_owned: 66.66
            end
            it 'only deducts first 100k of mortgage' do
              assessment.properties << main_home
              main_home = service.call.main_home
              expect(main_home.notional_sale_costs_pctg).to eq 3.0
              expect(main_home.net_value_after_deduction).to eq 452_983.21
              expect(main_home.maximum_mortgage_allowance).to eq 100_000.0
              expect(main_home.net_value_after_mortgage).to eq 352_983.21
              expect(main_home.percentage_owned).to eq 66.66
              expect(main_home.net_equity_value).to eq 235_298.61
              expect(main_home.property_disregard).to eq 100_000.0
              expect(main_home.assessed_capital_value).to eq 135_298.61
            end
          end

          context 'with mortgage < £100,000' do
            let(:main_home) do
              create :property,
                     :main_home,
                     :not_shared_ownership,
                     value: 466_993,
                     outstanding_mortgage: 37_256.44,
                     percentage_owned: 66.66
            end
            it 'only deducts the actual outstanding amount' do
              assessment.properties << main_home
              main_home = service.call.main_home
              expect(main_home.notional_sale_costs_pctg).to eq 3.0
              expect(main_home.net_value_after_deduction).to eq 452_983.21
              expect(main_home.maximum_mortgage_allowance).to eq 37_256.44
              expect(main_home.net_value_after_mortgage).to eq 415_726.77
              expect(main_home.percentage_owned).to eq 66.66
              expect(main_home.net_equity_value).to eq 277_123.46
              expect(main_home.property_disregard).to eq 100_000.0
              expect(main_home.assessed_capital_value).to eq 177_123.46
            end
          end
        end

        context '50% shared with housing association' do
          let(:main_home) do
            create :property,
                   :main_home,
                   :shared_ownership,
                   value: 160_000,
                   outstanding_mortgage: 70_000,
                   percentage_owned: 50.0
          end
          it 'subtracts outstanding mortgage only from the share owned by applicant' do
            assessment.properties << main_home
            main_home = service.call.main_home
            expect(main_home.notional_sale_costs_pctg).to eq 3.0
            expect(main_home.net_value_after_deduction).to eq 155_200.0
            expect(main_home.maximum_mortgage_allowance).to eq 70_000.0
            expect(main_home.net_value_after_mortgage).to eq 85_200.0
            expect(main_home.percentage_owned).to eq 50.0
            expect(main_home.net_equity_value).to eq 5_200.0
            expect(main_home.property_disregard).to eq 100_000.0
            expect(main_home.assessed_capital_value).to eq 0.0
          end
        end
      end

      context 'additional_properties and main dwelling' do
        let(:main_home) do
          create :property,
                 :main_home,
                 :not_shared_ownership,
                 value: 220_000,
                 outstanding_mortgage: 35_000,
                 percentage_owned: 100.0
        end

        let(:first_additional_property) do
          create :property,
                 :additional_property,
                 :not_shared_ownership,
                 value: 350_000,
                 outstanding_mortgage: 55_000,
                 percentage_owned: 100.0
        end

        let(:second_additional_property) do
          create :property,
                 :additional_property,
                 :not_shared_ownership,
                 value: 270_000,
                 outstanding_mortgage: 40_000,
                 percentage_owned: 100.0
        end

        context 'main dwelling wholly owned and additional properties wholly owned' do
          it 'deducts a maximum of £100k mortgage' do
            assessment.properties << main_home
            assessment.properties << first_additional_property
            assessment.properties << second_additional_property

            result = service.call
            ap1 = result.additional_properties.first
            expect(ap1.notional_sale_costs_pctg).to eq 3.0
            expect(ap1.net_value_after_deduction).to eq 339_500.0
            expect(ap1.maximum_mortgage_allowance).to eq 55_000.0
            expect(ap1.net_value_after_mortgage).to eq 284_500.0
            expect(ap1.percentage_owned).to eq 100.0
            expect(ap1.net_equity_value).to eq 284_500.0
            expect(ap1.property_disregard).to eq 0.0
            expect(ap1.assessed_capital_value).to eq 284_500.0

            ap2 = result.additional_properties[1]
            expect(ap2.notional_sale_costs_pctg).to eq 3.0
            expect(ap2.net_value_after_deduction).to eq 261_900.0
            expect(ap2.maximum_mortgage_allowance).to eq 40_000.0
            expect(ap2.net_value_after_mortgage).to eq 221_900.0
            expect(ap2.percentage_owned).to eq 100.0
            expect(ap2.net_equity_value).to eq 221_900.0
            expect(ap2.property_disregard).to eq 0.0
            expect(ap2.assessed_capital_value).to eq 221_900.0

            mh = result.main_home
            expect(mh.notional_sale_costs_pctg).to eq 3.0
            expect(mh.net_value_after_deduction).to eq 213_400
            expect(mh.maximum_mortgage_allowance).to eq 5_000.0
            expect(mh.net_value_after_mortgage).to eq 208_400.0
            expect(mh.percentage_owned).to eq 100.0
            expect(mh.net_equity_value).to eq 208_400.0
            expect(mh.property_disregard).to eq 100_000.0
            expect(mh.assessed_capital_value).to eq 108_400.0
          end
        end
      end

      context 'additional property but no main dwelling' do
        let(:additional_property) do
          create :property,
                 :additional_property,
                 :not_shared_ownership,
                 value: 350_000,
                 outstanding_mortgage: 55_000,
                 percentage_owned: 100.0
        end

        it 'calculates the additional property correctly' do
          assessment.properties << additional_property
          result = service.call
          ap = result.additional_properties.first
          expect(ap.notional_sale_costs_pctg).to eq 3.0
          expect(ap.net_value_after_deduction).to eq 339_500.0
          expect(ap.maximum_mortgage_allowance).to eq 55_000.0
          expect(ap.net_value_after_mortgage).to eq 284_500.0
          expect(ap.percentage_owned).to eq 100.0
          expect(ap.net_equity_value).to eq 284_500.0
          expect(ap.property_disregard).to eq 0.0
          expect(ap.assessed_capital_value).to eq 284_500.0
          expect(result.main_home).to be_empty
        end
      end
    end
  end
end
