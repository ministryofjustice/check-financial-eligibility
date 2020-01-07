require 'rails_helper'

module Assessors
  RSpec.describe MainAssessor do
    describe '.call' do
      let(:assessment) { create :assessment, :with_capital_summary, :with_gross_income_summary, :with_disposable_income_summary, :with_applicant }
      let(:capital_summary) { assessment.capital_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:applicant) { asssessment.applicant }

      before do
        capital_summary.update!(assessment_result: capital_result)
        gross_income_summary.update!(assessment_reusult: gross_income_result)
        disposable_income_summary.update!(asssessment_result: disposable_income_result)
      end

      subject { described_class.call(asfile.
  end
end
