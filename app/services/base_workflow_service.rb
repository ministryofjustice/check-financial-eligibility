class BaseWorkflowService
  attr_accessor :particulars

  REQUEST_METHODS = %i[meta_data applicant applicant_income applicant_outgoings applicant_capital].freeze
  RESPONSE_METHODS = %i[response_capital response_income response_contributions].freeze

  def initialize(assessment)
    @assessment = assessment
    @calculation_period = CalculationPeriod.new(@assessment.submission_date)
  end

  # # method missing - enables the following shortcut methods:
  # #
  # # * meta_data               @particulars.response.meta_data
  # # * applicant               @particulars.response.applicant
  # # * applicant_income        @particulars.response.applicant_income
  # # * applicant_outgoings     @particulars.response.applicant_outgoings
  # # * applicant_capital       @particulars.response.applicant_capital
  # # * response_capital        @particulars.response.details.capital
  # # * response_income         @particulars.response.income
  # # * response_contributions  @particulars.response.contributions
  # #
  # def method_missing(meth, *params)
  #   if meth.in?(REQUEST_METHODS)
  #     @particulars.request.__send__(meth)
  #   elsif meth.in?(RESPONSE_METHODS)
  #     actual_method = meth.to_s.sub(/^response_/, '')
  #     @particulars.response.details.__send__(actual_method)
  #   else
  #     super
  #   end
  # end

  # def respond_to_missing?(method, _include_private = false)
  #   method.in?(RESPONSE_METHODS + REQUEST_METHODS)
  # end
end
