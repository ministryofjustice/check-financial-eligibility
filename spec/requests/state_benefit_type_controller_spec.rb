require "rails_helper"

RSpec.describe StateBenefitTypeController, type: :request do
  describe "GET state benefit types" do
    let!(:state_benefit_type1) { create :state_benefit_type }

    it "returns http success" do
      get state_benefit_type_index_path
      expect(response).to have_http_status(:success)
    end

    it "returns an array of state benefit types" do
      get state_benefit_type_index_path
      expected_values = {
        name: state_benefit_type1.name,
        label: state_benefit_type1.label,
        dwp_code: state_benefit_type1.dwp_code,
        exclude_from_gross_income: state_benefit_type1.exclude_from_gross_income,
        category: state_benefit_type1.category,
      }.stringify_keys

      expect(JSON.parse(response.body).first).to include(expected_values)
    end
  end

  context "full list for documentation" do
    it "returns http success", :show_in_doc do
      StateBenefitType.delete_all
      Dibber::Seeder.new(StateBenefitType, "data/state_benefit_types.yml", name_method: :label, overwrite: true).build
      get state_benefit_type_index_path
      expect(response).to have_http_status(:success)
      StateBenefitType.delete_all
    end
  end
end
