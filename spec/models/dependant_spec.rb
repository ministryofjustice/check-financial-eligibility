require "rails_helper"

RSpec.describe Dependant, type: :model do
  let(:dependant) { build_stubbed(:dependant) }

  describe "#validate" do
    context "when date_of_birth is in the future" do
      let(:dependant) { build_stubbed(:dependant, date_of_birth: Date.tomorrow) }

      before { freeze_time }

      it "is invalid" do
        expect(dependant).to be_invalid
        expect(dependant.errors).to be_added(
          :date_of_birth,
          :less_than_or_equal_to,
          count: Date.current,
          value: Date.tomorrow,
        )
      end
    end

    context "when all attributes are valid" do
      it "is valid" do
        dependant = build_stubbed(:dependant)

        expect(dependant).to be_valid
      end
    end
  end
end
