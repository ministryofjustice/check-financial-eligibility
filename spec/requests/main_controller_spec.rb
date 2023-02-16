require "rails_helper"

describe MainController, type: :request do
  describe "GET /" do
    it "redirects to the api-docs" do
      get root_path
      expect(response).to redirect_to("/api-docs")
    end
  end
end
