module Creators
  class EmploymentsCreator < BaseCreator
    attr_accessor :assessment_id, :employments_attributes

    def initialize(assessment_id:, employment: [])
      super()
      @assessment_id = assessment_id
      @employment_income = employment[:employment_income]
    end

    def call
      create
      self
    end

    private

    def create
      create_employment
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_employment
      # return if @employment_income.blank?
      # So I create an employment record with monthly_employment_income and monthly_employment_deductions as 0.0
      # then I create an associated employments_payments record with the details from the submission e.g. gross_income, benefits_in_kind etc
      # which come from employments_attributes
      Employment.create(monthly_employment_income: 0.0, monthly_employment_deductions: 0.0 )
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
    end
  end
end