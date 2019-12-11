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

  describe '#summarise!' do
    let(:data) do
      {
        total_liquid: Faker::Number.decimal,
        total_non_liquid: Faker::Number.decimal,
        total_vehicle: Faker::Number.decimal,
        total_mortgage_allowance: Faker::Number.decimal,
        total_property: Faker::Number.decimal,
        pensioner_capital_disregard: Faker::Number.decimal,
        total_capital: Faker::Number.decimal,
        assessed_capital: Faker::Number.decimal,
        lower_threshold: Faker::Number.decimal,
        upper_threshold: Faker::Number.decimal
      }
    end

    subject { capital_summary.summarise! }

    before do
      allow(Collators::CapitalCollator).to receive(:call).with(assessment).and_return(data)
      subject
      capital_summary.reload
    end

    it 'persists the data' do
      data.each do |method, value|
        expect(capital_summary.__send__(method).to_d).to eq(value.to_d)
      end
    end

    it 'sets assessment result to summarised' do
      expect(capital_summary).to be_summarised
    end
  end

  describe '#determine_result!' do
    let(:capital_summary) { create :capital_summary, :below_lower_threshold }

    subject { capital_summary.determine_result! }

    before do
      subject
      capital_summary.reload
    end

    it 'set result to eligible' do
      expect(capital_summary).to be_eligible
    end

    context 'between thresholds' do
      let(:capital_summary) { create :capital_summary, :between_thresholds }

      it 'sets result to contribution_required' do
        expect(capital_summary).to be_contribution_required
      end
    end

    context 'above upper threshold' do
      let(:capital_summary) { create :capital_summary, :above_upper_threshold }

      it 'sets result to contribution_required' do
        expect(capital_summary).to be_contribution_required
      end
    end
  end
end
