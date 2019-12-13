require 'rails_helper'

RSpec.describe CapitalSummary do
  let(:assessment) { create :assessment }
  let(:additional_properties) { build_list :property, 2, :additional_property }
  let(:properties) { additional_properties }
  let(:capital_summary) do
    create :capital_summary, assessment: assessment, properties: properties
  end

  describe '#own_home' do
    it 'returns nil' do
      expect(capital_summary.main_home).to be_nil
    end

    context 'a main home exists' do
      let(:main_home) { create :property, :main_home }
      let(:properties) { [main_home] + additional_properties }

      it 'returns the main home property' do
        expect(capital_summary.main_home).to eq main_home
      end
    end
  end
end
