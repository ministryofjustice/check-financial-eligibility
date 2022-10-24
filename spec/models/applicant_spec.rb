require "rails_helper"

RSpec.describe Applicant, type: :model do
  describe "#validate" do
    let(:applicant) { build_stubbed(:applicant) }

    context "when date_of_birth is in the future" do
      let(:applicant) { build_stubbed(:applicant, date_of_birth: Date.tomorrow) }

      before { freeze_time }

      it "is invalid" do
        expect(applicant).to be_invalid
        expect(applicant.errors).to be_added(
          :date_of_birth,
          :less_than_or_equal_to,
          count: Date.current,
          value: Date.tomorrow,
        )
      end
    end

    context "when all attributes are valid" do
      it "is valid" do
        expect(applicant).to be_valid
      end
    end
  end

  describe "#age_at_submission" do
    let(:age) { 31 }
    let(:date_of_birth) { (age.years + 6.months).ago }
    let(:submission_date) { 1.day.ago }
    let(:assessment) { create :assessment, submission_date: }
    let(:applicant) { create :applicant, date_of_birth:, assessment: }

    it "returns the age" do
      expect(applicant.age_at_submission).to eq(age)
    end

    context "with old assessment" do
      let(:submission_date) { 8.months.ago }

      it "returns age at submission" do
        expect(applicant.age_at_submission).to eq(age - 1)
      end
    end
  end
end
