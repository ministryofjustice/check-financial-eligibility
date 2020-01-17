require 'rails_helper'

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) { create :assessment, :with_gross_income_summary, applicant: applicant }

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

        before { assessment.gross_income_summary.update! assessment_result: 'ineligible' }

        it 'collates and assesses gross income but not disposable' do
          expect(Collators::GrossIncomeCollator).to receive(:call).with(assessment)
          expect(Assessors::GrossIncomeAssessor).to receive(:call).with(assessment)
          expect(Collators::OutgoingsCollator).not_to receive(:call)
          expect(Assessors::DisposableIncomeAssessor).not_to receive(:call)

          subject
        end
      end

      context 'not employed, not self_employed, Gross income does not exceed threshold' do
        let(:applicant) { create :applicant, self_employed: false }

        before { assessment.gross_income_summary.update! assessment_result: 'eligible' }

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
