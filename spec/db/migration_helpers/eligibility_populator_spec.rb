require "rails_helper"
require Rails.root.join("db/migration_helpers/eligibility_populator")

RSpec.describe MigrationHelpers::EligibilityPopulator do
  let!(:assessment1) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary, :with_capital_summary }
  let!(:assessment2) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary, :with_capital_summary }
  let!(:assessment3) { create :assessment, :with_gross_income_summary, :with_disposable_income_summary, :with_capital_summary }
  let(:assessments) { [assessment1, assessment2, assessment3] }

  subject { described_class.call }

  context "migration has not yet been run" do
    it "has created a gross_income eligibility for each assessment" do
      expect { subject }.to change { Eligibility::GrossIncome.count }.by(3)
      assessments.each do |assessment|
        gis = assessment.gross_income_summary
        expect(gis.eligibilities.count).to eq 1
        eligibility = gis.eligibilities.first
        expect(eligibility.proceeding_type_code).to eq "DA001"
        expect(eligibility.upper_threshold).to eq gis.upper_threshold
        expect(eligibility.assessment_result).to eq "pending"
      end
    end

    it "has created a disposable income eligibility record for each assessment" do
      expect { subject }.to change { Eligibility::DisposableIncome.count }.by(3)
      assessments.each do |assessment|
        dis = assessment.disposable_income_summary
        expect(dis.eligibilities.count).to eq 1
        eligibility = dis.eligibilities.first
        expect(eligibility.proceeding_type_code).to eq "DA001"
        expect(eligibility.upper_threshold).to eq dis.upper_threshold
        expect(eligibility.lower_threshold).to eq dis.lower_threshold
        expect(eligibility.assessment_result).to eq "pending"
      end
    end

    it "has created a capital eligibility record for each assessment" do
      expect { subject }.to change { Eligibility::Capital.count }.by(3)
      assessments.each do |assessment|
        cap = assessment.capital_summary
        expect(cap.eligibilities.count).to eq 1
        eligibility = cap.eligibilities.first
        expect(eligibility.proceeding_type_code).to eq "DA001"
        expect(eligibility.upper_threshold).to eq cap.upper_threshold
        expect(eligibility.lower_threshold).to eq cap.lower_threshold
        expect(eligibility.assessment_result).to eq "pending"
      end
    end
  end

  context "migration has already run once" do
    before { subject }

    it 'does not create additional eligibility records' do
      expect { subject }.not_to change(Eligibility::GrossIncome, :count)
      expect { subject }.not_to change(Eligibility::DisposableIncome, :count)
      expect { subject }.not_to change(Eligibility::Capital, :count)
    end
  end

  context "the migration has already been done" do
    it "does not create new records" do
      CapitalSummary.all.each { |rec| rec.update(assessment_result: "migrated_to_eligibility") }
      GrossIncomeSummary.all.each { |rec| rec.update(assessment_result: "migrated_to_eligibility") }
      DisposableIncomeSummary.all.each { |rec| rec.update(assessment_result: "migrated_to_eligibility") }

      expect { subject }.not_to change(Eligibility::GrossIncome, :count)
      expect { subject }.not_to change(Eligibility::DisposableIncome, :count)
      expect { subject }.not_to change(Eligibility::Capital, :count)
    end
  end

  context "assessments without summary records" do
    before { create :assessment } # create 4th assessment with no summary records

    it "ignores assessments without summary records" do
      expect(Eligibility::GrossIncome.count).to eq 0
      expect(Eligibility::DisposableIncome.count).to eq 0
      expect(Eligibility::Capital.count).to eq 0

      subject

      # Eligibility records are only created for those assessments with summary records
      expect(Eligibility::GrossIncome.count).to eq 3
      expect(Eligibility::DisposableIncome.count).to eq 3
      expect(Eligibility::Capital.count).to eq 3
    end
  end
end
