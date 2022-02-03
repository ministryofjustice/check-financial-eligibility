require "rails_helper"

RSpec.describe StateBenefit do
  let(:gross_income_summary) { create :gross_income_summary }

  let!(:excluded_state_benefit_type) { create :state_benefit_type, exclude_from_gross_income: true }

  describe ".generate!" do
    context "an excluded state benefit" do
      subject(:benefit) { described_class.generate!(gross_income_summary, excluded_state_benefit_type.name) }

      it "has a link to gross income summary" do
        expect(benefit.gross_income_summary_id).to eq gross_income_summary.id
      end

      it "has a link to state benefit type" do
        expect(benefit.state_benefit_type_id).to eq excluded_state_benefit_type.id
      end

      it "name is blank" do
        expect(benefit.name).to be_blank
      end
    end

    context "other state benefit" do
      let!(:other_state_benefit_type) { create :state_benefit_type, :other }

      subject(:other_benefit) { described_class.generate!(gross_income_summary, "my_special_benefit") }

      it "has a link to gross income summary" do
        expect(other_benefit.gross_income_summary_id).to eq gross_income_summary.id
      end

      it "has a link to other state benefit" do
        benefit_type = other_benefit.state_benefit_type
        expect(benefit_type.label).to eq other_state_benefit_type.label
      end

      it "name is not blank" do
        expect(other_benefit.name).to eq "my_special_benefit"
      end
    end
  end
end
