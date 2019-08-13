require 'rails_helper'

RSpec.describe IntegrationTests::UseCaseRunner do
  let(:assessment) { attributes_for :assessment }
  let(:applicant) { attributes_for :applicant }
  let(:dependants) { attributes_for_list(:dependant, 2) }
  let(:bank_accounts) { attributes_for_list(:bank_account, 2) }
  let(:non_liquid_assets) { attributes_for_list(:non_liquid_asset, 2) }
  let(:vehicles) { attributes_for_list(:vehicle, 2) }
  let(:additional_properties) { attributes_for_list(:property, 2) }
  let(:main_home) { attributes_for :property }
  let(:benefits) { attributes_for_list(:benefit_receipt, 2) }
  let(:wage_slips) { attributes_for_list(:wage_slip, 2) }
  let(:outgoings) { attributes_for_list(:outgoing, 2) }
  let(:payload) do
    {
      assessment: assessment,
      applicant: applicant,
      dependants: dependants,
      capital: {
        liquid_capital: {
          bank_accounts: bank_accounts
        },
        non_liquid_capital: non_liquid_assets
      },
      vehicles: vehicles,
      properties: {
        main_home: main_home.except(:main_home),
        additional_properties: additional_properties.map do |home|
          home.except(:main_home)
        end
      },
      income: {
        benefits: benefits,
        wage_slips: wage_slips
      },
      outgoings: outgoings
    }
  end

  subject { described_class.call('http://localhost:3000', payload) }

  describe '#call', :vcr do
    it 'does not raises any error' do
      subject
    end

    context 'payload is not valid' do
      let(:assessment) { nil }

      it 'raises any error' do
        expect { subject }.to raise_error(/Unprocessable Entity/)
      end
    end
  end
end
