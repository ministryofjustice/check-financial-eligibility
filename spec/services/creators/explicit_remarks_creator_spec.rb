require "rails_helper"

RSpec.describe Creators::ExplicitRemarksCreator do
  describe ".call" do
    subject(:call) { described_class.call(assessment:, explicit_remarks_params: params) }

    let(:assessment) { create :assessment }

    let(:valid_params) do
      {
        explicit_remarks: [
          {
            category: "policy_disregards",
            details: %w[disregard_1 disregard_2],
          },
        ],
      }
    end

    context "with valid payload" do
      let(:params) { valid_params }

      it "#success? is true" do
        expect(call.success?).to be true
      end

      it "creates the expected number of records" do
        expect { call }.to change(ExplicitRemark, :count).by(2)
      end

      it "creates expected record data" do
        call
        remarks = ExplicitRemark.where(assessment_id: assessment.id, category: "policy_disregards").map(&:remark)
        expect(remarks).to match_array(%w[disregard_1 disregard_2])
      end
    end

    context "with invalid payload" do
      let(:params) do
        {
          explicit_remarks: [
            {
              category: "invalid",
              details: %w[disregard_1 disregard_2],
            },
          ],
        }
      end

      it "stores the error on the object" do
        expect(call.success?).to be false
        expect(call.errors).to eq ["Category invalid is not a valid remark category"]
      end
    end
  end
end
