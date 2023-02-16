require "rails_helper"

module Creators
  RSpec.describe AssessmentCreator do
    before { stub_call_to_json_schema }

    let(:remote_ip) { "127.0.0.1" }
    let(:raw_post_v3) do
      {
        client_reference_id: "psr-123",
        submission_date: "2019-06-06",
      }.to_json
    end

    let(:raw_post_v4) do
      {
        client_reference_id: "psr-123",
        submission_date: "2019-06-06",
        proceeding_types: {
          ccms_codes: %w[DA005 SE003 SE014],
        },
      }.to_json
    end

    let(:raw_post_v5) do
      {
        client_reference_id: "psr-123",
        submission_date: "2019-06-06",
      }.to_json
    end

    let(:raw_post_controlled) do
      {
        client_reference_id: "psr-123",
        submission_date: "2019-06-06",
        level_of_representation: "controlled",
      }.to_json
    end

    subject(:creator) { described_class.call(remote_ip:, assessment_params:, version:) }

    context "version 5" do
      let(:assessment_params) { raw_post_v5 }
      let(:version) { "5" }

      context "valid request" do
        it "is successful" do
          expect(creator.success?).to eq true
        end

        it "creates an Assessment record" do
          expect { creator.success? }.to change(Assessment, :count).by(1)
        end

        it "populates the assessment record with expected values" do
          creator.success?
          assessment = Assessment.first
          expect(assessment.version).to eq "5"
          expect(assessment.remote_ip).to eq "127.0.0.1"
          expect(assessment.proceeding_type_codes).to eq []
          expect(assessment.level_of_representation).to eq "certificated"
        end

        it "creates a CapitalSummary record" do
          expect { creator.success? }.to change(CapitalSummary, :count).by(1)
        end

        it "has no errors" do
          expect(creator.errors).to be_empty
        end

        describe "#as_json" do
          it "returns a successful json struct including the assessment it has created" do
            creator.success?

            expected_response = {
              success: true,
              assessment_id: Assessment.last.id,
              errors: [],
            }
            expect(creator.as_json).to eq expected_response
          end
        end
      end
    end

    context "when version 5" do
      let(:assessment_params) { raw_post_v5 }
      let(:version) { "5" }

      context "valid request" do
        it "is successful" do
          expect(creator.success?).to eq true
        end

        it "creates an Assessment record" do
          expect { creator.success? }.to change(Assessment, :count).by(1)
        end

        it "populates the assessment record with expected values" do
          creator.success?
          assessment = Assessment.first
          expect(assessment.version).to eq "5"
          expect(assessment.remote_ip).to eq "127.0.0.1"
          expect(assessment.proceeding_type_codes).to eq []
        end

        it "creates a CapitalSummary record" do
          expect { creator.success? }.to change(CapitalSummary, :count).by(1)
        end

        it "has no errors" do
          expect(creator.errors).to be_empty
        end

        describe "#as_json" do
          it "returns a successful json struct including the assessment it has created" do
            creator.success?

            expected_response = {
              success: true,
              assessment_id: Assessment.last.id,
              errors: [],
            }
            expect(creator.as_json).to eq expected_response
          end
        end
      end

      context "invalid request" do
        let(:remote_ip) { nil }

        it "is not successful" do
          expect(creator.success?).to be false
        end

        it "does not create an Assessment record" do
          expect { creator.success? }.not_to change(Assessment, :count)
        end

        it "has errors" do
          expect(creator.errors).to include("Remote ip can't be blank")
        end
      end

      context "when level of representation is specified" do
        let(:assessment_params) { raw_post_controlled }

        it "sets the level appropriately" do
          expect(creator.success?).to eq true
          expect(Assessment.first.level_of_representation).to eq "controlled"
        end
      end
    end
  end
end
