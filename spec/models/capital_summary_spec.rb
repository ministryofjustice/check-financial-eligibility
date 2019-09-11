require 'rails_helper'

RSpec.describe CapitalSummary do
  let(:assessment) { create :assessment }
  let(:capital_summary) { assessment.capital_summary }

  describe '#own_home' do
    before do
      capital_summary.properties << create(:property, :additional_property)
      capital_summary.properties << create(:property, :additional_property)
    end

    context 'a main home exists' do
      it 'returns the one and only property which is a main home' do
        main_home = build :property, :main_home
        capital_summary.properties << main_home
        capital_summary.save
        expect(capital_summary.main_home).to eq main_home
      end
    end

    context 'no main home' do
      it 'returns nil' do
        expect(capital_summary.main_home).to be_nil
      end
    end
  end

  describe '#result' do
    before do
      capital_summary.liquid_capital_items << create(:liquid_capital_item, description: 'Royal Bank of Scotland 16552933', value: 250.22)
      capital_summary.liquid_capital_items << create(:liquid_capital_item, description: 'Santander 2909043664', value: 30.25)
      capital_summary.non_liquid_capital_items << create(:non_liquid_capital_item, description: 'JR Ewing trust fund', value: 37_764.66)
      capital_summary.non_liquid_capital_items << create(:non_liquid_capital_item, description: 'Ming vase', value: 340_000.00)
      capital_summary.properties << create(:property,
                                           :main_home,
                                           value: 830_000,
                                           outstanding_mortgage: 250_000,
                                           percentage_owned: 100,
                                           transaction_allowance: 24_900,
                                           allowable_outstanding_mortgage: 100_000,
                                           net_value: 125_100,
                                           net_equity: 125_100,
                                           main_home_equity_disregard: 100_000,
                                           assessed_equity: 25_100)
      capital_summary.properties << create(:property,
                                           :additional_property,
                                           value: 250_000,
                                           outstanding_mortgage: 0,
                                           percentage_owned: 100,
                                           transaction_allowance: 7_500,
                                           allowable_outstanding_mortgage: 0,
                                           net_value: 242_500,
                                           net_equity: 242_500,
                                           main_home_equity_disregard: 0,
                                           assessed_equity: 242_500)
      capital_summary.vehicles << create(:vehicle,
                                         date_of_purchase: 2.years.ago.to_date,
                                         value: 5_600,
                                         loan_amount_outstanding: 1_200,
                                         in_regular_use: true,
                                         included_in_assessment: false)
    end

    it 'renders result as hash' do
      expected_result = {
        total_capital_assessment: 0.0,
        pensioner_capital_disregard: 0.0,
        total_disposable_capital: 0.0,
        total_capital_test: 'pending',
        capital_contribution: 0.0,
        total_liquid_capital: 0.0,
        liquid_capital_items: [
          { 'Royal Bank of Scotland 16552933' => 250.22 },
          { 'Santander 2909043664' => 30.25 }
        ],
        total_non_liquid_capital: 0.0,
        non_liquid_capital_items: [
          { 'JR Ewing trust fund' => 37_764.66 },
          { 'Ming vase' => 340_000.00 }
        ],
        property: { total_property_assessment: 0.0,
                    total_mortgage_allowance: 0.0,
                    additional_properties: [
                      { value: 250_000.0,
                        transaction_allowance: 7_500.0,
                        allowable_outstanding_mortgage: 0.0,
                        net_value: 242_500.0,
                        percentage_share: 100.0,
                        net_equity: 242_500.0,
                        main_home_equity_disregard: 0.0,
                        assessed_equity: 242_500.0 }
                    ],
                    main_home: { value: 830_000.0,
                                 transaction_allowance: 24_900.0,
                                 allowable_outstanding_mortgage: 100_000.0,
                                 net_value: 125_100.0,
                                 percentage_share: 100.0,
                                 net_equity: 125_100.0,
                                 main_home_equity_disregard: 100_000.0,
                                 assessed_equity: 25_100.0 } },
        total_vehicles_value: 0.0,
        vehicles: [
          {
            date_purchased: 2.years.ago.to_date,
            months_owned: 24,
            estimated_value: 5_600.0,
            outstanding_loan: 1_200.0,
            in_regular_use: true,
            included_in_assessment: false,
            assessed_value: 0.0
          }
        ]
      }
      expect(capital_summary.result).to eq expected_result
    end
  end
end
