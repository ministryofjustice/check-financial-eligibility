require 'rails_helper'

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) { create :assessment, :with_everything, applicant: applicant }

    before do
      assessment.proceeding_type_codes.each do |ptc|
        create :capital_eligibility, capital_summary: assessment.capital_summary, proceeding_type_code: ptc
        create :gross_income_eligibility, gross_income_summary: assessment.gross_income_summary, proceeding_type_code: ptc
        create :disposable_income_eligibility, disposable_income_summary: assessment.disposable_income_summary, proceeding_type_code: ptc
      end
    end

    describe '.call' do
      subject { described_class.call(assessment) }

      context 'self_employed' do
        let(:applicant) { create :applicant, self_employed: true }

        it 'calls the self-employed workflow' do
          expect(SelfEmployedWorkflow).to receive(:call).with(assessment)
          subject
        end
      end

      context 'not employed, not self_employed, Gross income exceeds threshold' do
        let(:applicant) { create :applicant, self_employed: false }

        before do
          assessment.gross_income_summary.eligibilities.map { |elig| elig.update! assessment_result: 'ineligible' }
        end

        it 'collates and assesses gross income but not disposable' do
          expect(Collators::GrossIncomeCollator).to receive(:call).with(assessment)
          expect(Assessors::GrossIncomeAssessor).to receive(:call).with(assessment)
          expect(Assessors::DisposableIncomeAssessor).not_to receive(:call)

          subject
        end
      end

      context 'not employed, not self_employed, Gross income does not exceed threshold' do
        let(:applicant) { create :applicant, self_employed: false }

        before do
          assessment.gross_income_summary.eligibilities.map { |elig| elig.update! assessment_result: 'eligible' }
        end

        it 'collates and assesses gross income, outgoings and perfoms disposable assessment' do
          expect(Collators::GrossIncomeCollator).to receive(:call).with(assessment)
          expect(Assessors::GrossIncomeAssessor).to receive(:call).with(assessment)
          expect(Collators::OutgoingsCollator).to receive(:call).with(assessment)
          expect(Assessors::DisposableIncomeAssessor).to receive(:call).with(assessment)

          subject
        end
      end
    end
  end
end
