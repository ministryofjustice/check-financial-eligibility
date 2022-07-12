require "rails_helper"

RSpec.describe ProceedingType do
  let(:assessment) { create :assessment }

  describe "ccms_code" do
    it "errors if invalid" do
      pt = described_class.new(ccms_code: "ZZ1234", client_involvement_type: "A", assessment:)
      expect(pt).not_to be_valid
      expect(pt.errors[:ccms_code]).to eq ["invalid ccms_code: ZZ1234"]
    end
  end

  describe "client_involvement_type" do
    it "errors if invalid" do
      pt = described_class.new(ccms_code: "DA001", client_involvement_type: "X", assessment:)
      expect(pt).not_to be_valid
      expect(pt.errors[:client_involvement_type]).to eq ["invalid client_involvement_type: X"]
    end
  end

  describe "valid proceeding_type" do
    it "writes proceeding_type to the database" do
      expect {
        described_class.create(ccms_code: ProceedingTypeThreshold.valid_ccms_codes.sample,
                               client_involvement_type: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES.sample,
                               assessment:)
      }.to change(described_class, :count).by(1)
    end
  end
end
