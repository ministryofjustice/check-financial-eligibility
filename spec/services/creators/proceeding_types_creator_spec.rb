require "rails_helper"

module Creators
  RSpec.describe ProceedingTypesCreator do
    include Rails.application.routes.url_helpers
    let(:assessment) { create :assessment, proceedings: [] }
    let(:proceeding_types_attributes) { attributes_for_list(:proceeding_type, 2) }
    let(:proceeding_types_params) { { proceeding_types: proceeding_types_attributes } }

    subject(:creator) { described_class.call(assessment:, proceeding_types_params:) }

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
        before do
          creator
        end

        let(:result) { ProceedingType.all }

        it "returns the created proceeding_types" do
          expect(result.count).to eq(proceeding_types_attributes.count)
          expect(result.first).to be_a(ProceedingType)
          expect(result.first.assessment.id).to eq(assessment.id)
        end
      end
    end
  end
end
