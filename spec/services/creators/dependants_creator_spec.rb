require 'rails_helper'

module Creators
  RSpec.describe DependantsCreator do
    include Rails.application.routes.url_helpers
    let(:assessment) { create :assessment }
    let(:assessment_id) { assessment.id }
    let(:dependants_attributes) { attributes_for_list(:dependant, 2) }

    subject { described_class.call(assessment_id:, dependants_attributes:) }

    context 'valid payload' do
      it 'creates two dependant records for this assessment' do
        expect { subject }.to change { assessment.dependants.count }.by(dependants_attributes.count)

        dependants_attributes.each do |dependant_attributes|
          dependant = assessment.dependants.find_by!(date_of_birth: dependant_attributes[:date_of_birth])
          dependant_attributes.each_key do |key|
            expect(dependant[key].to_s).to eq(dependant_attributes[key].to_s),
                                           "Dependent attribute `#{key}` mismatch: #{dependant[key].inspect}, #{dependant_attributes[key].inspect}"
          end
        end
      end

      describe '#success?' do
        it 'returns true' do
          expect(subject).to be_success
        end
      end

      describe '#dependants' do
        it 'returns the created dependants' do
          expect(subject.dependants.count).to eq(dependants_attributes.count)
          expect(subject.dependants.first).to be_a(Dependant)
          expect(subject.dependants.first.assessment.id).to eq(assessment.id)
        end
      end
    end

    context 'payload fails ActiveRecord validations' do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2, date_of_birth: Faker::Date.forward) }

      describe '#success?' do
        it 'returns false' do
          expect(subject.success?).to be false
        end

        it 'does not create a Dependant record' do
          expect { subject }.not_to change { Dependant.count }
        end
      end

      describe 'errors' do
        it 'returns an error payload' do
          expect(subject.errors.size).to eq 1
          expect(subject.errors).to include 'Date of birth cannot be in future'
        end
      end
    end

    context 'no such assessment id' do
      let(:assessment_id) { SecureRandom.uuid }

      describe '#success?' do
        it 'returns false' do
          expect(subject.success?).to be false
        end

        it 'does not create a Dependant record' do
          expect { subject }.not_to change { Dependant.count }
        end
      end

      describe 'errors' do
        it 'returns an error payload' do
          expect(subject.errors.size).to eq 1
          expect(subject.errors[0]).to eq 'No such assessment id'
        end
      end
    end
  end
end
