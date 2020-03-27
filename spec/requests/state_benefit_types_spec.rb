require 'rails_helper'

RSpec.describe StateBenefitTypeController, type: :request do
  let!(:state_benefit_type) { create :state_benefit_type }
  let(:name) { state_benefit_type.name }
  let(:label) { state_benefit_type.label }
  let(:dwp_code) { state_benefit_type.dwp_code }

  describe 'GET state benefit types' do
    subject { get state_benefit_type_index_path }
    before do
      subject
    end

    it 'is successful' do
      expect(response).to have_http_status(200)
    end

    it 'returns an array of state benefit types' do
      state_benefit_types = { name: name, label: label, dwp_code: dwp_code }.stringify_keys
      expect(JSON.parse(response.body)).to contain_exactly(state_benefit_types)
    end
  end
end
