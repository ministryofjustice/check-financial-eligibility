require 'rails_helper'

module RemarkGenerators
  RSpec.describe Orchestrator do
    let(:assessment) { create :assessment }
    let(:state_benefits) { assessment.gross_income_summary.state_benefits }
    let(:state_benefit_payments) { state_benefits.first.state_benefit_payments }
    let(:other_income_sources) { assessment.gross_income_summary.other_income_sources }
    let(:other_income_payments) { other_income_sources.first.other_income_payments }
    let(:childcare_outgoings) { assessment.disposable_income_summary.childcare_outgoings }
    let(:maintenance_outgoings) { assessment.disposable_income_summary.maintenance_outgoings }
    let(:housing_outgoings) { assessment.disposable_income_summary.housing_cost_outgoings }
    let(:legal_aid_outgoings) { assessment.disposable_income_summary.legal_aid_outgoings }

    before do
      create :disposable_income_summary, :with_everything, assessment: assessment
      create :gross_income_summary, :with_everything, assessment: assessment
    end

    it 'calls the checkers with each collection' do
      expect(AmountVariationChecker).to receive(:call).with(assessment, state_benefit_payments)
      expect(AmountVariationChecker).to receive(:call).with(assessment, other_income_payments)
      expect(AmountVariationChecker).to receive(:call).with(assessment, childcare_outgoings)
      expect(AmountVariationChecker).to receive(:call).with(assessment, maintenance_outgoings)
      expect(AmountVariationChecker).to receive(:call).with(assessment, housing_outgoings)
      expect(AmountVariationChecker).to receive(:call).with(assessment, legal_aid_outgoings)
      expect(ResidualBalanceChecker).to receive(:call).with(assessment)

      described_class.call(assessment)
    end
  end
end
