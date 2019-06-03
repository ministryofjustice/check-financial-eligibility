class BaseWorkflowService
  attr_accessor :particulars

  REQUEST_METHODS = %i[applicant applicant_income applicant_outgoings applicant_capital].freeze
  RESPONSE_METHODS = %i[response].freeze

  def initialize(particulars)
    @particulars = particulars
    @submission_date = Date.parse(@particulars.request.meta_data.submission_date)
    @calculation_period = CalculationPeriod.new(@submission_date)
  end

  def method_missing(meth, *params)
    if meth.in?(REQUEST_METHODS)
      @particulars.request.__send__(meth)
    elsif meth.in?(RESPONSE_METHODS)
      @particulars.response
    else
      super
    end
  end

  def respond_to_missing?(method, _include_private = false)
    method.in?(RESPONSE_METHODS + REQUEST_METHODS)
  end
end
