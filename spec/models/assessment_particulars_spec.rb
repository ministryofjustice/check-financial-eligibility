require 'rails_helper'

RSpec.describe AssessmentParticulars do
  let(:assessment) { create :assessment }
  let(:particulars) { described_class.new(assessment) }
  let(:request_hash) { JSON.parse(assessment.request_payload).deep_symbolize_keys }

  context '.new' do
    context 'request' do
      let(:request) { particulars.request }

      describe '#meta_data' do
        it 'is same as specified in request payload' do
          particulars.request.meta_data
          expect(request.meta_data).to eq OpenStruct.new(request_hash[:meta_data])
        end
      end

      context '#applicant' do
        context '#date_of_birth' do
          it 'is as specified in the request_payload and formatted as YYYY-MM-DD' do
            expect(request.applicant.date_of_birth).to eq request_hash[:applicant][:date_of_birth]
          end
        end
      end

      context 'accessing arrays of objects' do
        context '#dependents' do
          it 'is an array of 2 RecursiveOpenStructs' do
            dependants = request.applicant.dependants
            expect(dependants).to be_instance_of(Array)
            expect(dependants.size).to eq 2
            expect(dependants.first).to be_instance_of(OpenStruct)
            expect(dependants.last).to be_instance_of(OpenStruct)
          end

          it 'can be accessed an an item level' do
            dependants = request.applicant.dependants
            expect(dependants.first.in_full_time_education).to eq(request_hash[:applicant][:dependants][0][:in_full_time_education])
          end
        end
      end
    end

    context 'response' do
      it 'stores the assessment_id' do
        particulars
        expect(particulars.response.assessment_id).to eq assessment.id
      end

      it 'stores the client_reference_id' do
        expect(particulars.response.client_reference_id).to eq assessment.client_reference_id
      end

      describe '#details' do
        it 'is an empty RecursiveOpenStruct' do
          expect(particulars.response.details).to eq OpenStruct.new({})
        end

        it 'can be populated' do
          particulars.response.details.total_capital_assessment
          particulars.response.details.total_capital_assessment = 2_855.55
          expect(particulars.response.details.total_capital_assessment).to eq 2_855.55
        end
      end

      describe '#errors' do
        it 'is an empty array' do
          expect(particulars.response.errors).to eq []
        end

        it 'can be populated' do
          particulars.response.errors << 'error_1'
          particulars.response.errors << 'error_2'
          expect(particulars.response.errors).to eq %w[error_1 error_2]
        end
      end
    end
  end

  context 'method_missing' do
    context 'unknown method with no arguments' do
      it 'it returns nil' do
        expect(particulars.xxx).to be nil
      end
    end

    context 'unknown setter method' do
      it 'adds a new element to the structure' do
        expect {
          particulars.zzz = 'ZZZ'
        }.to raise_error NoMethodError, /undefined method `zzz='/
      end
    end

    context 'unknown method  with arguments' do
      it 'raises NoMethodError' do
        expect {
          particulars.aaa('param1')
        }.to raise_error NoMethodError, /undefined method `aaa'/
      end
    end
  end

  context '#respond_to?' do
    context 'unknown method with no arguments' do
      it 'it returns true' do
        expect(particulars.respond_to?(:xxx)).to be false
      end
    end

    context 'unknown setter method' do
      it 'adds a new element to the structure' do
        expect {
          particulars.zzz = 'ZZZ'
        }.to raise_error NoMethodError, /undefined method `zzz='/
      end
    end

    context 'unknown method  with arguments' do
      it 'raises NoMethodError' do
        expect {
          particulars.aaa('param1')
        }.to raise_error NoMethodError, /undefined method `aaa'/
      end
    end
  end
end
