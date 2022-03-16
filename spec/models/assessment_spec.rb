require "rails_helper"
require Rails.root.join("spec/fixtures/assessment_request_fixture.rb")

RSpec.describe Assessment, type: :model do
  let(:payload) { AssessmentRequestFixture.json }

  context "version 3" do
    context "missing matter proceeding type" do
      let(:param_hash) do
        {
          client_reference_id: "client-ref-1",
          submission_date: Date.current,
          remote_ip: "127.0.0.1",
          version: "3",
        }
      end

      it "errors" do
        assessment = described_class.create param_hash
        expect(assessment.persisted?).to be false
        expect(assessment.valid?).to be false
        expect(assessment.errors.full_messages).to include("Matter proceeding type can't be blank")
      end
    end
  end

  context "version 4" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
        proceeding_type_codes: ccms_codes,
        remote_ip: "127.0.0.1",
        version: "4",
      }
    end

    context "missing matter proceeding type codes" do
      let(:ccms_codes) { nil }

      it "errors" do
        param_hash.delete(:proceeding_type_codes)
        assessment = described_class.create param_hash
        expect(assessment.persisted?).to be false
        expect(assessment.valid?).to be false
        expect(assessment.errors.full_messages).to include("Proceeding type codes can't be blank")
      end
    end

    context "no proceeding types specified" do
      let(:ccms_codes) { [] }

      it "errors" do
        assessment = described_class.create param_hash
        expect(assessment.persisted?).to be false
        expect(assessment.valid?).to be false
        expect(assessment.errors.full_messages).to include("Proceeding type codes can't be blank")
      end
    end

    context "invalid proceeding type codes" do
      let(:ccms_codes) { %w[DA005 SE014 XX999 SE003] }

      it "errors" do
        assessment = described_class.create param_hash
        expect(assessment.persisted?).to be false
        expect(assessment.valid?).to be false
        expect(assessment.errors.full_messages).to include("Proceeding type codes invalid: XX999")
      end
    end

    context "valid params" do
      let(:ccms_codes) { %w[DA005 SE014 SE003 DA020] }

      it "writes a valid record" do
        assessment = described_class.create! param_hash
        expect(assessment).to be_valid
      end
    end
  end

  context "missing ip address" do
    let(:param_hash) do
      {
        client_reference_id: "client-ref-1",
        submission_date: Date.current,
        matter_proceeding_type: "domestic_abuse",
        version: "3",
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
end
