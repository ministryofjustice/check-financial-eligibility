class IncomesController < ApplicationController
  api :POST, 'assessments/:assessment_id/incomes', 'Create incomes'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param(
    :wage_slips,
    Array,
    desc: 'An array of objects describing each wage slip received during the calculation period',
    required: true
  ) do
    param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date upon which the payment was received'
    param :gross_pay, :currency, required: true, desc: 'Gross pay before deductions'
    param :paye, :currency, required: true, desc: 'Income tax deducted from gross pay'
    param :nic, :currency, required: true, desc: 'National Insurance contribution deducted from gross pay'
  end

  param(
    :benefits,
    Array,
    desc: 'An array of objects describing each benefit payment received during the calculation period',
    required: true
  ) do
    param :benefit_name, BenefitReceipt.benefit_names.values, required: true, desc: 'The type of benefit received'
    param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date the benefit payment was received'
    param :amount, :currency, required: true, desc: 'The amount received'
  end

  returns code: :ok, desc: 'Successful response' do
    property :wage_slips, array_of: WageSlip
    property :benefits, array_of: BenefitReceipt
    property :success, ['true'], desc: 'Success flag shows true'
  end
  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if income_creation_service.success?
      render json: income_creation_service
    else
      render_unprocessable(income_creation_service.errors)
    end
  end

  private

  def income_creation_service
    @income_creation_service ||= IncomeCreationService.call(
      assessment_id: params[:assessment_id],
      benefits: input[:benefits],
      wage_slips: input[:wage_slips]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end
