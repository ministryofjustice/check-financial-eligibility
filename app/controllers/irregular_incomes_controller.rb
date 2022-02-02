class IrregularIncomesController < ApplicationController
  resource_description do
    name "Irregular incomes"
    short "Add irregular types of income details to an assessment"
    formats(%w[json])
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicant's irregular income payments to an assessment.
    END_OF_TEXT
  end

  api :POST, "assessments/:assessment_id/irregular_incomes", "Create irregular incomes"
  formats(%w[json])
  param :assessment_id, :uuid, required: true
  param :payments, Array, of: Hash, desc: "Collection of payment types, frequencies and amounts" do
    param :income_type, CFEConstants::VALID_IRREGULAR_INCOME_TYPES, required: true, desc: "An identifying name for this irregular income payment"
    param :frequency, CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES, required: true, desc: "The frequency of the payment received"
    param :amount, :currency, currency_option: :not_negative, required: true, desc: "Amount of payment"
  end

  returns code: :ok, desc: "Successful response" do
    property :success, %w[true], desc: "Success flag shows true"
    property :errors, [], desc: "Empty array of error messages"
  end
  returns code: :unprocessable_entity do
    property :success, %w[false], desc: "Success flag shows false"
    property :errors, array_of: String, desc: "Description of why object invalid"
  end

  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::IrregularIncomeCreator.call(
      assessment_id: params[:assessment_id],
      irregular_income: irregular_income_params,
    )
  end

  def irregular_income_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
