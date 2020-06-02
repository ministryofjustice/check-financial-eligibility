require 'rails_helper'

RSpec.describe StateBenefitTypeController, type: :request do
  let!(:state_benefit_type_1) { create :state_benefit_type }
  let!(:state_benefit_type_2) { create :state_benefit_type }
  let(:name) { state_benefit_type_1.name }
  let(:label) { state_benefit_type_1.label }
  let(:dwp_code) { state_benefit_type_1.dwp_code }
  let(:exclude) { state_benefit_type_1.exclude_from_gross_income }
  let(:category) { state_benefit_type_1.category }

  describe 'GET state benefit types' do
    subject { get state_benefit_type_index_path }
    before do
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns an array of state benefit types' do
      expected_values = {
        name: name,
        label: label,
        dwp_code: dwp_code,
        exclude_from_gross_income: exclude,
        category: category
      }.stringify_keys
      expect(JSON.parse(response.body).first).to include(expected_values)
    end
  end

  context 'full list for documentation' do
    it 'returns http success', :show_in_doc do
      StateBenefitType.delete_all
      Dibber::Seeder.new(StateBenefitType, 'data/state_benefit_types.yml', name_method: :label, overwrite: true).build
      get state_benefit_type_index_path
      expect(response).to have_http_status(:success)
    end
  end
end
