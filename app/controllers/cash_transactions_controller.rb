class CashTransactionsController < ApplicationController
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
