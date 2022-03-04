module Calculators
  class MultipleEmploymentsCalculator
    delegate :disposable_income_summary,
             :gross_income_summary,
             :submission_date,
             to: :assessment

    attr_reader :assessment

    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      ActiveRecord::Base.transaction do
        update_gross_income_summary
        update_disposable_income_summary
        add_remarks
      end
    end

  private

    def update_gross_income_summary
      gross_income_summary.update(
        gross_employment_income: 0.0,
        benefits_in_kind: 0.0,
      )
    end

    def update_disposable_income_summary
      disposable_income_summary.update(
        employment_income_deductions: 0.0,
        tax: 0.0,
        national_insurance: 0.0,
        fixed_employment_allowance: Threshold.value_for(:fixed_employment_allowance, at: submission_date),
      )
    end

    def add_remarks
      my_remarks = assessment.remarks
      my_remarks.add(:employment, :multiple_employments, employment_client_ids)
      assessment.update!(remarks: my_remarks)
    end

    def employment_client_ids
      assessment.employments.map(&:client_id)
    end
  end
end
