require 'rails_helper'

RSpec.describe CapitalSummary do
  let(:assessment) { create :assessment }
  let(:capital_summary) { assessment.capital_summary }

  describe 'own_home' do
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
end
