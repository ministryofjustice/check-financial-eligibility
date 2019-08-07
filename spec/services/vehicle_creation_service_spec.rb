require 'rails_helper'

RSpec.describe VehicleCreationService do
  let(:assessment) { create :assessment }
  let(:vehicles_attributes) { attributes_for_list(:vehicle, 2) }

  describe `.call` do
    subject do
      described_class.call(
        assessment_id: assessment.id,
        vehicles_attributes: vehicles_attributes
      )
    end

    it 'generates two vehicles' do
      expect { subject }.to change { assessment.vehicles.count }.by(2)
    end

    it 'is successful' do
      expect(subject).to be_success
    end

    it 'has empty errors' do
      expect(subject.errors).to be_empty
    end

    context 'with error' do
      let(:vehicles_attributes) { attributes_for_list(:vehicle, 2, date_of_purchase: Faker::Date.between(from: 2.months.from_now, to: 6.years.from_now)) }

      it 'does not generates two vehicles' do
        expect { subject }.not_to change { assessment.vehicles.count }
      end

      it 'is unsuccessful' do
        expect(subject).not_to be_success
      end

      it 'returns an error' do
        expect(subject.errors).to eq(['Date of purchase cannot be in the future'])
      end
    end
  end
end
