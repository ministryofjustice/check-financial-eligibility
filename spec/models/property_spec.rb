require 'rails_helper'

RSpec.describe Property, type: :model do
  let(:assessment) { create :assessment }
  let(:valid_attrs) do
    {
      assessment_id: assessment.id,
      value: 100_000,
      outstanding_mortgage: 50_000,
      percentage_owned: 50,
      main_home: true,
      shared_with_housing_assoc: false
    }
  end

  context 'validations' do
    context 'valid attributes' do
      it 'is valid' do
        expect(Property.new(valid_attrs)).to be_valid
      end
    end

    context 'invalid' do
      let(:prop) { Property.new(attrs) }
      context 'value' do
        let(:attrs) { valid_attrs.merge(value: 0) }
        context 'zero' do
          it 'errors' do
            expect(prop).not_to be_valid
            expect(prop.errors[:value]).to eq ['must be greater than 0']
          end
        end
      end

      context 'mortgage' do
        context 'zero' do
          let(:attrs) { valid_attrs.merge(outstanding_mortgage: 0) }
          it 'does not error' do
            expect(prop).to be_valid
          end
        end
        context 'negative' do
          let(:attrs) { valid_attrs.merge(outstanding_mortgage: -1000) }
          it 'errors' do
            expect(prop).not_to be_valid
            expect(prop.errors[:outstanding_mortgage]).to eq ['must be greater than or equal to 0']
          end
        end
      end

      context 'percentage_owned' do
        context 'negative' do
          let(:attrs) { valid_attrs.merge(percentage_owned: -25) }
          it 'errors' do
            expect(prop).not_to be_valid
            expect(prop.errors[:percentage_owned]).to eq ['must be greater than or equal to 0']
          end
        end

        context 'more than 100' do
          let(:attrs) { valid_attrs.merge(percentage_owned: 125) }
          it 'errors' do
            expect(prop).not_to be_valid
            expect(prop.errors[:percentage_owned]).to eq ['must be less than or equal to 100']
          end
        end

        context 'valid value' do
          let(:attrs) { valid_attrs.merge(percentage_owned: 75) }
          it 'does not error' do
            expect(prop).to be_valid
          end
        end
      end
    end
  end
end
