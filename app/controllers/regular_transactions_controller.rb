class RegularTransactionsController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render "regular_transactions", regular_transaction_params, lambda {
      Creators::RegularTransactionsCreator.call(
        gross_income_summary: @assessment.gross_income_summary,
        regular_transaction_params:,
      )
    }
  end

private

  def regular_transaction_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
