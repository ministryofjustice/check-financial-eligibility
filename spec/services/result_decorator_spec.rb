require 'rails_helper'

describe ResultDecorator do
  let(:assessment) { create :assessment, :with_applicant }
  let(:option) { :below_lower_threshold }
  let!(:capital_summary) { create :capital_summary, option, assessment: assessment }

  subject { described_class.new(assessment) }

  describe '#as_json' do
    it 'includes result' do
      expect(subject.as_json[:assessment_result]).to eq(assessment.capital_assessment_result)
    end

    it 'includes applicant' do
      expect(subject.as_json[:applicant]).to eq(subject.applicant_hash)
    end

    it 'includes capital hash' do
      expect(subject.as_json[:capital]).to eq(subject.capital_hash)
    end

    it 'includes property hash' do
      expect(subject.as_json[:property]).to eq(subject.property_hash)
    end

    it 'includes vehicles hash' do
      expect(subject.as_json[:vehicles]).to eq(subject.vehicles_hash)
    end
  end

  describe '#applicant_hash' do
    let(:applicant) { assessment.applicant }

    it 'returns hash' do
      expect(subject.applicant_hash).to be_a(Hash)
    end

    it 'returns benefit data' do
      expect(subject.applicant_hash['receives_qualifying_benefit']).to eq(applicant.receives_qualifying_benefit)
    end

    it 'returns age' do
      expect(subject.applicant_hash['age_at_submission']).to eq(applicant.age_at_submission)
    end
  end

  describe '#capital_hash' do
    let!(:non_liquid_capital_item) { create :non_liquid_capital_item, capital_summary: capital_summary }
    let!(:liquid_capital_item) { create :liquid_capital_item, capital_summary: capital_summary }
    it 'returns hash' do
      expect(subject.capital_hash).to be_a(Hash)
    end

    it 'returns capital summary data' do
      expect(subject.capital_hash['total_capital']).to eq(capital_summary.total_capital.to_s)
    end

    it 'returns liquid capital detail' do
      descriptions = subject.capital_hash['liquid_capital_items'].pluck('description')
      expect(descriptions).to include(liquid_capital_item.description)
    end

    it 'returns non liquid capital detail' do
      values = subject.capital_hash['non_liquid_capital_items'].pluck('value')
      expect(values).to include(non_liquid_capital_item.value.to_s)
    end
  end

  describe '#property_hash' do
    let!(:main_home) { create :property, :main_home, capital_summary: capital_summary }
    let!(:property) { create :property, :additional_property, capital_summary: capital_summary }
    it 'returns hash' do
      expect(subject.property_hash).to be_a(Hash)
    end

    it 'includes total data' do
      expect(subject.property_hash['total_property']).to eq(capital_summary.total_property.to_s)
    end

    it 'includes main home data' do
      expect(subject.property_hash.dig('main_home', 'main_home_equity_disregard')).to eq(main_home.main_home_equity_disregard.to_s)
    end

    it 'includes additional property data' do
      values = subject.property_hash['additional_properties'].pluck('value')
      expect(values).to include(property.value.to_s)
    end
  end

  describe 'vehicles_hash' do
    let!(:vehicle) { create :vehicle, capital_summary: capital_summary }
    it 'returns hash' do
      expect(subject.vehicles_hash).to be_a(Hash)
    end

    it 'returns vehicles total' do
      expect(subject.vehicles_hash['total_vehicle']).to eq(capital_summary.total_vehicle.to_s)
    end

    it 'returns vehicle data' do
      values = subject.vehicles_hash['vehicles'].pluck('value')
      expect(values).to include(vehicle.value.to_s)
    end
  end
end
