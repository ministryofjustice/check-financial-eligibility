require "rails_helper"
require Rails.root.join("spec/fixtures/assessment_request_fixture.rb")

RSpec.describe Assessment, type: :model do
  let(:payload) { AssessmentRequestFixture.json }

  context "version 5" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
        remote_ip: "127.0.0.1",
        version: "5",
      }
    end

    it "writes current date into the date column" do
      assessment = described_class.create! param_hash
      expect(assessment.created_at).to eq(Date.current)
      expect(assessment.updated_at).to eq(Date.current)
    end
  end

  context "missing ip address" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
        version: "5",
      }
    end

    it "errors" do
      assessment = described_class.create param_hash
      expect(assessment.persisted?).to be false
      expect(assessment.valid?).to be false
      expect(assessment.errors.full_messages).to include("Remote ip can't be blank")
    end
  end

  describe "#remarks" do
    context "nil value in database" do
      it "instantiates a new empty Remarks object" do
        assessment = create :assessment, remarks: nil
        expect(assessment.remarks.class).to eq Remarks
        expect(assessment.remarks.as_json).to eq Remarks.new(assessment.id).as_json
      end
    end

    context "saving and reloading" do
      let(:remarks) do
        r = Remarks.new(assessment.id)
        r.add(:other_income_payment, :unknown_frequency, %w[abc def])
        r.add(:other_income_payment, :amount_variation, %w[ghu jkl])
        r
      end

      let(:assessment) { create :assessment }

      before { assessment.remarks = remarks }

      it "reconstitutes into a remarks class with the same values" do
        expect(assessment.remarks.as_json).to eq remarks.as_json
      end
    end

    context "error handling" do
      it "instantiates a new empty Remarks object when there is an attributes failure" do
        assessment = create :assessment, remarks: "remarks"
        allow(assessment).to receive(:attributes).and_raise(StandardError.new("error"))
        expect(assessment.remarks.class).to eq Remarks
        expect(assessment.remarks.as_json).to eq Remarks.new(assessment.id).as_json
      end
    end
  end

  describe "#proceeding_type_codes" do
    it "returns the codes from the associated proceeding type records" do
      assessment = create :assessment, proceedings: [%w[DA005 A], %w[SE014 Z]]

      expect(assessment.reload.proceeding_type_codes).to eq %w[DA005 SE014]
    end
  end
end
