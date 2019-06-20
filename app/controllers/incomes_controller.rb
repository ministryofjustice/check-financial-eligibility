class IncomesController < ApplicationController
  def create
    result = IncomeCreationService.call(request.raw_post)
    render json: result, status: result.success? ? 200 : 422
  end
end
