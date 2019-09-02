require 'rails_helper'

RSpec.describe Applicant do
  describe 'age_in_years' do
    let(:assessment) { create :assessment, submission_date: submission_date }
    let(:applicant) { create :applicant, assessment: assessment, date_of_birth: Date.new(1953, 8, 13) }

    context 'submission date before the birthday' do
      let(:submission_date) { Date.new 2019, 8, 12 }
      it 'returns the correct age' do
        expect(applicant.age_in_years).to eq 65
      end
    end

    context 'submission date on birthday' do
      let(:submission_date) { Date.new 2019, 8, 13 }
      it 'returns the correct age' do
        expect(applicant.age_in_years).to eq 66
      end
    end

    context 'submission date after birthday' do
      let(:submission_date) { Date.new 2019, 8, 14 }
      it 'returns the correct age' do
        expect(applicant.age_in_years).to eq 66
      end
    end
  end
end
