class CashTransactionsController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("cash_transaction", cash_transaction_params, lambda {
      Creators::CashTransactionsCreator.call(
        assessment: @assessment,
        cash_transaction_params:,
      )
    })
  end

private

  def cash_transaction_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
