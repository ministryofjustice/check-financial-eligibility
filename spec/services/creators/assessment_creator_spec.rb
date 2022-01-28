require "rails_helper"

module Creators
  RSpec.describe AssessmentCreator do
    before { mock_lfa_responses }

    let(:remote_ip) { "127.0.0.1" }
    let(:raw_post_v3) do
      {
        client_reference_id: "psr-123",
        submission_date: "2019-06-06",
        matter_proceeding_type: "domestic_abuse",
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

    subject { described_class.call(remote_ip:, raw_post:, version:) }

    before { stub_call_to_json_schema }

    context "version 3" do
      let(:raw_post) { raw_post_v3 }
      let(:version) { "3" }

      context "valid request" do
        it "is successful" do
          expect(subject.success?).to eq true
        end

        it "creates an Assessment record" do
          expect { subject.success? }.to change(Assessment, :count).by(1)
        end

        it "writes the dummy proceeding type code on the assessment record" do
          subject.success?
          assessment = Assessment.first
          expect(assessment.proceeding_type_codes).to eq ["DA001"]
        end

        it "creates a CapitalSummary record" do
          expect { subject.success? }.to change(CapitalSummary, :count).by(1)
        end

        context "capital summary record" do
          before { subject.success? }

          let(:capital_summary) { CapitalSummary.first }

          it "creates all fields as zero" do
            expect(capital_summary.total_liquid).to eq 0.0
            expect(capital_summary.total_non_liquid).to eq 0.0
            expect(capital_summary.total_vehicle).to eq 0.0
            expect(capital_summary.total_property).to eq 0.0
            expect(capital_summary.total_mortgage_allowance).to eq 0.0
            expect(capital_summary.pensioner_capital_disregard).to eq 0.0
            expect(capital_summary.assessed_capital).to eq 0.0
            expect(capital_summary.capital_contribution).to eq 0.0
            expect(capital_summary.total_capital).to eq 0.0
            expect(capital_summary.pensioner_capital_disregard).to eq 0.0
            expect(capital_summary.lower_threshold).to eq 0.0
            expect(capital_summary.assessed_capital).to eq 0.0
            expect(capital_summary.upper_threshold).to eq 0.0
          end
        end

        it "has no errors" do
          expect(subject.errors).to be_empty
        end

        describe "#as_json" do
          it "returns a successful json struct including the assessment it has created" do
            subject.success?
            expected_response = {
              success: true,
              assessment_id: Assessment.last.id,
              errors: [],
            }
            expect(subject.as_json).to eq expected_response
          end
        end
      end

      context "invalid request" do
        let(:remote_ip) { nil }

        it "is not successful" do
          expect(subject.success?).to be false
        end

        it "does not create an Assessment record" do
          expect { subject.success? }.not_to change(Assessment, :count)
        end

        it "has  errors" do
          expect(subject.errors).to eq ["Remote ip can't be blank"]
        end
      end
    end

    context "version 4" do
      let(:raw_post) { raw_post_v4 }
      let(:version) { "4" }

      context "valid request" do
        it "is successful" do
          expect(subject.success?).to eq true
        end

        it "creates an Assessment record" do
          expect { subject.success? }.to change(Assessment, :count).by(1)
        end

        it "populates the assessment record with expected values" do
          subject.success?
          assessment = Assessment.first
          expect(assessment.version).to eq "4"
          expect(assessment.remote_ip).to eq "127.0.0.1"
          expect(assessment.matter_proceeding_type).to be_nil
          expect(assessment.proceeding_type_codes).to eq %w[DA005 SE003 SE014]
        end

        it "creates a CapitalSummary record" do
          expect { subject.success? }.to change(CapitalSummary, :count).by(1)
        end

        context "capital summary record" do
          before { subject.success? }

          let(:capital_summary) { CapitalSummary.first }

          it "creates all fields as zero" do
            expect(capital_summary.total_liquid).to eq 0.0
            expect(capital_summary.total_non_liquid).to eq 0.0
            expect(capital_summary.total_vehicle).to eq 0.0
            expect(capital_summary.total_property).to eq 0.0
            expect(capital_summary.total_mortgage_allowance).to eq 0.0
            expect(capital_summary.pensioner_capital_disregard).to eq 0.0
            expect(capital_summary.assessed_capital).to eq 0.0
            expect(capital_summary.capital_contribution).to eq 0.0
            expect(capital_summary.total_capital).to eq 0.0
            expect(capital_summary.pensioner_capital_disregard).to eq 0.0
            expect(capital_summary.lower_threshold).to eq 0.0
            expect(capital_summary.assessed_capital).to eq 0.0
            expect(capital_summary.upper_threshold).to eq 0.0
          end
        end

        it "has no errors" do
          expect(subject.errors).to be_empty
        end

        describe "#as_json" do
          it "returns a successful json struct including the assessment it has created" do
            subject.success?

            expected_response = {
              success: true,
              assessment_id: Assessment.last.id,
              errors: [],
            }
            expect(subject.as_json).to eq expected_response
          end
        end
      end

      context "invalid request" do
        let(:remote_ip) { nil }

        it "is not successful" do
          expect(subject.success?).to be false
        end

        it "does not create an Assessment record" do
          expect { subject.success? }.not_to change(Assessment, :count)
        end

        it "has  errors" do
          expect(subject.errors).to include("Remote ip can't be blank")
        end
      end
    end
  end
end
