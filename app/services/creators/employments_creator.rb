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
      @employments_incomes.each do |job|
        @assessment.employments.create!(assessment_id: assessment_id,
                           name: job[:name])

        job[:payments].each do |payment|
          emp = Employment.find_by(assessment_id: assessment_id, name: job[:name])
          emp.employment_payments.create!(employment_id: emp.id,
                                    date: payment[:date],
                                    gross_income: payment[:gross],
                                    benefits_in_kind: payment[:benefits_in_kind],
                                    tax: payment[:tax],
                                    national_insurance: payment[:national_insurance] )
        end
      end
    end

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
    end
  end
end