class StatusController < ApplicationController
  def index
    render json: { alive: true }
  end
end
