class OtherIncomesController < ApplicationController
  resource_description do
    short "Add other types of income details to an assessment"
    formats(%w[json])
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicant's other income sources to an assessment.
    END_OF_TEXT
  end

  api :POST, "assessments/:assessment_id/other_incomes", "Create other income"
  formats(%w[json])
  param :assessment_id, :uuid, required: true
  param :other_incomes, Array, desc: "Collection of other regular income sources" do
    param :source, CFEConstants::HUMANIZED_INCOME_CATEGORIES, required: true, desc: "An identifying name the source of this income"
    param :payments, Array, desc: "Collection of payment dates and amounts" do
      param :date, Date, date_option: :today_or_older, required: true, desc: "The date payment received"
      param :amount, :currency, currency_option: :not_negative, required: true, desc: "Amount of payment"
      param :client_id, String, required: true, desc: "Uniquely identifying string from client"
    end
  end

  returns code: :ok, desc: "Successful response" do
    property :success, ["true"], desc: "Success flag shows true"
    property :errors, [], desc: "Empty array of error messages"
  end
  returns code: :unprocessable_entity do
    property :success, ["false"], desc: "Success flag shows false"
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
    @creation_service ||= Creators::OtherIncomesCreator.call(
      assessment_id: params[:assessment_id],
      other_incomes: other_income_params
    )
  end

  def other_income_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
