require 'rails_helper'

describe Applicant do

  describe '#age_at_submission' do
    let(:age) { 31 }
    let(:date_of_birth) { (age.years + 6.months).ago }
    let(:submission_date) { 1.day.ago }
    let(:assessment) { create :assessment, submission_date: submission_date }
    let(:applicant) { create :applicant, date_of_birth: date_of_birth, assessment: assessment }

    it 'returns the age' do
      expect(applicant.age_at_submission).to eq(age)
    end

    context 'with old assessment' do
      let(:submission_date) { 8.months.ago }
      it 'returns age at submission' do
        expect(applicant.age_at_submission).to eq(age - 1)
      end
    end
  end
end
