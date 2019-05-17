module Api
  class StatusesController < ApplicationController
    def index
      responses = Status.order(created_at: :desc)
      render json: { status: 'SUCCESS', message: 'Response Messages', data: responses }
    end

    # private

    # def status_params
    #   params.require(:status).permit(:response)
    # end
  end
end
