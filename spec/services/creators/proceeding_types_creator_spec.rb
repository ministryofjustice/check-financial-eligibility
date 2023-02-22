require "rails_helper"

module Creators
  RSpec.describe ProceedingTypesCreator do
    include Rails.application.routes.url_helpers
    let(:assessment) { create :assessment, proceedings: [] }
    let(:assessment_id) { assessment.id }
    let(:proceeding_types_attributes) { attributes_for_list(:proceeding_type, 2) }
    let(:proceeding_types_params) { { proceeding_types: proceeding_types_attributes } }

    subject(:creator) { described_class.call(assessment_id:, proceeding_types_params:) }

    context "with valid payload" do
      it "creates two proceeding_types records for this assessment" do
        expect { creator }.to change { assessment.proceeding_types.count }.by(proceeding_types_attributes.count)

        proceeding_types_attributes.each do |pt_attributes|
          pt = assessment.proceeding_types.find_by!(ccms_code: pt_attributes[:ccms_code])
          expect(pt.client_involvement_type).to eq(pt_attributes[:client_involvement_type])
        end
      end

      describe "#success?" do
        it "returns true" do
          expect(creator).to be_success
        end
      end

      describe "#proceeding_types" do
        it "returns the created proceeding_types" do
          expect(creator.proceeding_types.count).to eq(proceeding_types_attributes.count)
          expect(creator.proceeding_types.first).to be_a(ProceedingType)
          expect(creator.proceeding_types.first.assessment.id).to eq(assessment.id)
        end
      end
    end

    context "with no such assessment id" do
      let(:assessment_id) { SecureRandom.uuid }

      describe "#success?" do
        it "returns false" do
          expect(creator.success?).to be false
        end

        it "does not create a ProceedingType record" do
          expect { creator }.not_to change(ProceedingType, :count)
        end
      end

      describe "errors" do
        it "returns an error payload" do
          expect(creator.errors.size).to eq 1
          expect(creator.errors[0]).to eq "Creators::BaseCreator::CreationError - [\"No such assessment id\"]"
        end
      end
    end

    context "with invalid ccms_code" do
      let(:proceeding_types_attributes) { attributes_for_list(:proceeding_type, 1, :with_invalid_ccms_code) }

      it "returns false" do
        expect(creator.success?).to be false
      end

      it "returns an error message" do
        expect(creator.errors.size).to eq 1
        expect(creator.errors[0]).to match(/The property '#\/proceeding_types\/0\/ccms_code' value "XX1234" did not match one of the following values/)
      end
    end

    context "with invalid client_involvement_type" do
      let(:proceeding_types_attributes) { attributes_for_list(:proceeding_type, 1, :with_invalid_client_involvement_type) }

      it "returns false" do
        expect(creator.success?).to be false
      end

      it "returns an error message" do
        expect(creator.errors.size).to eq 1
        expect(creator.errors[0]).to match(/The property '#\/proceeding_types\/0\/client_involvement_type' value "X" did not match one of the following values/)
      end
    end

    context "with duplicate ccms_codes" do
      let(:proceeding_types_attributes) do
        [
          {
            ccms_code: "DA001",
            client_involvement_type: "A",
          },
          {
            ccms_code: "DA001",
            client_involvement_type: "I",
          },
        ]
      end

      it "returns false" do
        expect(creator.success?).to be false
      end

      it "returns an error message" do
        expect(creator.errors.size).to eq 1
        expect(creator.errors[0]).to match(/ActiveRecord::RecordNotUnique/)
      end
    end
  end
end
