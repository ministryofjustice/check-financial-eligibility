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
end
