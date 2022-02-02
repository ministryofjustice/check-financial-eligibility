class CashTransactionsController < ApplicationController
  resource_description do
    short "Add cash transactions to an assessment"
    formats(%w[json])
    description <<-END_OF_TEXT
    == Description
      Adds cash income and outgoings to and assessment so that they can be included in the means test.

    END_OF_TEXT
  end
  api :POST, "assessments/:assessment_id/cash_transactions", "Add cash income and outgoings"
  formats(%w[json])
  param :assessment_id, :uuid, required: true
  param :income, Array, of: Hash, desc: "Collection of Income categories" do
    param :category, CFEConstants::VALID_INCOME_CATEGORIES, required: true, desc: "An identifying name for this income category"
    param :payments, Array, of: Hash, desc: "Total payments received for this category in each of the three months preceding the assessment date" do
      param :date, Date, date_option: :today_or_older, required: true,
                         desc: "The date payment received (this must be the first day of one of the three months preceeding the assessment date"
      param :amount, :currency, currency_option: :not_negative, required: true, desc: "Amount of payment"
      param :client_id, String, required: true, desc: "Uniquely identifying string from client"
    end
  end
  param :outgoings, Array, of: Hash, desc: "Collection of Outgoing categories" do
    param :category, CFEConstants::VALID_OUTGOING_CATEGORIES, required: true, desc: "An identifying name for this outgoing category"
    param :payments, Array, of: Hash, desc: "Total payments made for this category in three consecutive months of the preceding four months" do
      param :date, Date, date_option: :today_or_older, required: true,
                         desc: "The date payment made (this must be the first day of one of the four preceding months"
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
    @creation_service ||= Creators::CashTransactionsCreator.call(
      assessment_id: params[:assessment_id],
      income: input[:income],
      outgoings: input[:outgoings],
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end
