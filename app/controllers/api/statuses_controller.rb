module API
  class StatusesController < ApplicationController
    def index
      responses = Status.order(created_at: :desc)
      render json: { status: "SUCCESS", message: "Response Messages", data: responses }
    end
  end
end
