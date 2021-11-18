module Creators
  class EmploymentsCreator < BaseCreator
    attr_accessor :assessment_id, :employments_attributes
    # attr_accessor :assessment_id

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
      assessment # I am not sure that this is required, this was part of my testing where I was getting assessment must exist error
      create_employment
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_employment
      # return if @employments_incomes.blank?
      # create an employment record with monthly_employment_income and monthly_employment_deductions as 0.0
      # create an associated employments_payments record with the details from the submission e.g. gross_income, benefits_in_kind etc
      # which come from employments_attributes
      ActiveRecord::Base.transaction do
        @employments_incomes.each do |employment|
          puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
          # Fails here with an error saying:
          # ActiveRecord::RecordInvalid: Validation failed: Assesssment must exist
          binding.pry
          assessment.employment.create!(assessment_id: assessment_id,
                             name: employment[:name],
                             monthly_employment_income: 0.0,
                             monthly_employment_deductions: 0.0 )
          employment.each do |payment|
            puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
            puts '3 payments should be created for each employment record'
            ap payment
            EmploymentPayment.create!(employment_id: employment.id,
                                      date: payment[:date],
                                      gross_income: payment[:gross_income],
                                      benefits_in_kind: payment[:benefits_in_kind],
                                      tax: payment[:tax],
                                      national_insurance: payment[:national_insurance] )
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        raise CreationError, e.record.errors.full_messages
      end
    end

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
    end
  end
end