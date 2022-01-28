require "rails_helper"

RSpec.describe StateBenefitType, type: :model do
  context "validations" do
    context "category" do
      it "validates valid options" do
        (%w[carer_disability low_income other uncategorised] + [nil]).each do |cat|
          rec = build :state_benefit_type, category: cat
          expect(rec).to be_valid
        end
      end

      it "rejects invalid options" do
        rec = build :state_benefit_type, category: "something_else"
        expect(rec).not_to be_valid
        expect(rec.errors[:category]).to eq ["Invalid category"]
      end
    end
  end
end
