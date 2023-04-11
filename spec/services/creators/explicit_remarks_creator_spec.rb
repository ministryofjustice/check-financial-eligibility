require "rails_helper"

RSpec.describe Creators::ExplicitRemarksCreator do
  describe ".call" do
    subject(:call) { described_class.call(assessment_id: assessment.id, explicit_remarks_params: params) }

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

    context "with valid payload but unknown exception raised" do
      let(:params) { valid_params }

      it "stores the error on the object" do
        allow_any_instance_of(described_class).to receive(:create_remark_category).and_raise(ArgumentError, "Argument error detailed message")
        expect(call.success?).to be false
        expect(call.errors).to eq ["ArgumentError - Argument error detailed message"]
      end
    end
  end
end
