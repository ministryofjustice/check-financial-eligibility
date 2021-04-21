require 'rails_helper'

module Assessors
  RSpec.describe MainAssessor do
    let(:assessment) do
      create :assessment,
             :with_capital_summary,
             :with_gross_income_summary,
             :with_disposable_income_summary,
             :with_eligibilities,
             :with_applicant
    end

    # TODO: write tests here that look at all the assessment_eligibility results and resturn eligible, ineligible, partly eligible
  end
end
