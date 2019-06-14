require 'rails_helper'

RSpec.describe ApplicantCreationService do
  describe 'POST applicant' do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(request_payload) }

    before do
      # stub requests to get schemas
      stub_request(:get, 'http://localhost:3000/schemas/assessment_request.json')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: full_schema, headers: {})
    end

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
          expect(service.success?).to be true
        end

        it 'creates an applicant' do
          expect { service.success? }.to change { Applicant.count }.by 1
        end
      end

      describe '#assessment' do
        it 'returns the assessment record' do
          expect(service.assessment).to eq assessment
        end
      end
    end

    context 'payload fails JSON Schema' do
      let(:invalid_payload) do
        {
          assessment_id: assessment.id,
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
          expect(service.success?).to be false
        end

        it 'returns errors' do
          service.success?
          expect(service.errors.size).to eq 4
          expect(service.errors[0]).to match %r{The property '#/applicant' did not contain a required property of 'has_partner_opponent'}
          expect(service.errors[1]).to match %r{The property '#/applicant' contains additional properties \[\"reason\"\]}
          expect(service.errors[2]).to match %r{The property '#/applicant/date_of_birth' value \"2010x-04-04\" did not match the regex }
          expect(service.errors[3]).to match %r{The property '#/' contains additional properties \[\"extra_property\"\] }
        end

        it 'does not create an applicant' do
          expect { service.success? }.not_to change { Applicant.count }
        end
      end
    end

    context 'ActiveRecord validation fails' do
      let(:invalid_payload) do
        {
          assessment_id: assessment.id,
          applicant: {
            date_of_birth: Date.tomorrow.to_date,
            involvement_type: 'applicant',
            has_partner_opponent: false,
            receives_qualifying_benefit: false
          }
        }.to_json
      end

      let(:request_payload) { invalid_payload }

      describe '#success?' do
        it 'returns false' do
          expect(service.success?).to be false
        end

        it 'returns errors' do
          service.success?
          expect(service.errors.size).to eq 1
          expect(service.errors[0]).to eq 'Date of birth cannot be in future'
        end

        it 'does not create an applicant' do
          expect { service.success? }.not_to change { Applicant.count }
        end
      end
    end

    def full_schema
      File.read(Rails.root.join('public/schemas/assessment_request.json'))
    end
  end
end
