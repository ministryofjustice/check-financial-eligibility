require 'rails_helper'

RSpec.describe ApplicantCreationService do
  describe 'POST applicant' do
    let(:assessment) { create :assessment }

    subject { described_class.call(request_payload) }

    before { stub_call_to_json_schema }

    describe '.call' do
      context 'valid payload' do
        let(:valid_payload) do
          {
            assessment_id: assessment.id,
            applicant: {
              date_of_birth: '2010-04-04',
              involvement_type: 'applicant',
              has_partner_opponent: true,
              receives_qualifying_benefit: true
            }
          }.to_json
        end

        let(:request_payload) { valid_payload }

        describe '#success?' do
          it 'returns true' do
            expect(subject.success?).to be true
          end

          it 'creates an applicant' do
            expect { subject.success? }.to change { Applicant.count }.by 1
          end
        end

        describe '#applicant' do
          it 'returns the applicant' do
            expect(subject.applicant).to be_a Applicant
          end
        end

        describe '#errors' do
          it 'should be empty' do
            expect(subject.errors).to be_empty
          end
        end
      end

      context 'with invalid JSON' do
        let(:invalid_payload) do
          {
            assessment_id: 'xxxx',
            extra_property: 'this should not be here',
            applicant: {
              date_of_birth: '2010x-04-04',
              involvement_type: 'applicant',
              receives_qualifying_benefit: false,
              reason: 'extra property'
            }
          }.to_json
        end

        let(:request_payload) { invalid_payload }

        describe '#success?' do
          it 'returns false' do
            expect(subject.success?).to be false
          end
        end

        describe '#applicant' do
          it 'returns empty array' do
            expect(subject.applicant).to be_nil
          end
        end

        describe '#errors' do
          it 'returns errors' do
            expect(subject.errors.size).to eq 5
            expect(subject.errors[0]).to match %r{The property '#/assessment_id' value \"xxxx\" did not match the regex}
            expect(subject.errors[1]).to match %r{The property '#/applicant' did not contain a required property of 'has_partner_opponent'}
            expect(subject.errors[2]).to match %r{The property '#/applicant' contains additional properties \[\"reason\"\]}
            expect(subject.errors[3]).to match %r{The property '#/applicant/date_of_birth' value \"2010x-04-04\" did not match the regex}
            expect(subject.errors[4]).to match %r{The property '#/' contains additional properties \[\"extra_property\"\]}
          end
        end

        it 'does not create an applicant' do
          expect { subject }.not_to change { Applicant.count }
        end
      end

      context 'ActiveRecord validation fails' do
        let(:valid_payload) do
          {
            assessment_id: assessment_id,
            applicant: {
              date_of_birth: date_of_birth,
              involvement_type: 'applicant',
              has_partner_opponent: true,
              receives_qualifying_benefit: true
            }
          }.to_json
        end
        let(:assessment_id) { assessment.id }
        let(:date_of_birth) { Date.today.to_date }
        let(:request_payload) { valid_payload }

        context 'date of birth cannot be in future' do
          let(:date_of_birth) { Date.tomorrow.to_date }

          describe '#success?' do
            it 'returns false' do
              expect(subject.success?).to be false
            end
          end

          describe '#applicant' do
            it 'returns empty array' do
              expect(subject.applicant).to be_nil
            end
          end

          describe '#errors' do
            it 'returns error' do
              expect(subject.errors.size).to eq 1
              expect(subject.errors[0]).to eq 'Date of birth cannot be in future'
            end
          end

          it 'does not create an applicant' do
            expect { subject }.not_to change { Applicant.count }
          end
        end

        context 'assessment id does not exist' do
          let(:assessment_id) { SecureRandom.uuid }

          it 'returns an error' do
            expect(subject.errors).to eq ['No such assessment id']
          end
        end

        context 'applicant already exists' do
          before { described_class.call(request_payload) }
          describe '#success?' do
            it 'returns false' do
              expect(subject.success?).to be false
            end
          end

          describe '#applicant' do
            it 'returns empty array' do
              expect(subject.applicant).to be_nil
            end
          end

          it 'does not create an applicant' do
            expect { subject }.not_to change { Applicant.count }
          end

          describe '#errors' do
            it 'returns error' do
              expect(subject.errors[0]).to eq 'There is already an applicant for this assesssment'
            end
          end
        end
      end
    end

    def full_schema
      File.read(Rails.root.join('public/schemas/assessment_request.json'))
    end
  end
end
