module Creators
  class EmploymentsCreator < BaseCreator
    attr_accessor :assessment_id, :employments_attributes

    def initialize(assessment_id:, employments_attributes: [])
      super()
      @assessment_id = assessment_id
      @employments_incomes = employments_attributes
    end

    def call
      create
      self
    end

  private

    def create
      ActiveRecord::Base.transaction do
        assessment
        create_employment
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_employment
      @employments_incomes.each do |employment|
        @assessment.employments.create!(assessment_id:,
                                        name: employment[:name])
        create_payments(employment)
      end
    end

    def create_payments(employment)
      employment[:payments].each do |income|
        emp = Employment.find_by(assessment_id:, name: employment[:name])
        emp.employment_payments.create!(employment_id: emp.id,
                                        date: income[:date],
                                        gross_income: income[:gross],
                                        benefits_in_kind: income[:benefits_in_kind],
                                        tax: income[:tax],
                                        national_insurance: income[:national_insurance])
      end
    end

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ["No such assessment id"])
    end
  end
end
