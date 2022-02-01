require "rails_helper"

RSpec.describe CapitalsController, type: :request do
  describe "POST capital" do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:assessment_id) { assessment.id }
    let(:params) do
      {
        bank_accounts: bank_account_params,
        non_liquid_capital: non_liquid_params,
      }
    end
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    subject(:post_payload) { post assessment_capitals_path(assessment_id), params: params.to_json, headers: headers }

    before { post_payload }

    context "valid payload" do
      context "with both types of assets" do
        it "returns http success", :show_in_doc do
          expect(response).to have_http_status(:success)
        end

        it "generates a valid response" do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end
      end

      context "with only bank_accounts" do
        let(:params) do
          {
            bank_accounts: bank_account_params,
          }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "generates a valid response" do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end

        it "creates two LiquidCapitalItem records" do
          expect(assessment.capital_summary.liquid_capital_items.size).to eq 2
        end
      end

      context "with only non-liquid assets" do
        let(:params) do
          {
            non_liquid_capital: non_liquid_params,
          }
        end

        it "returns http success" do
          expect(response).to have_http_status(:success)
        end

        it "generates a valid response" do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end

        it "creates 2 NonLiquidCapitalItem records" do
          expect(assessment.capital_summary.non_liquid_capital_items.size).to eq 2
        end
      end

      context "empty payload" do
        let(:params) { {} }

        it "returns http unprocessable entity" do
          expect(response).to have_http_status(:success)
        end

        it "returns error payload" do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end
      end

      context "Active Record error" do
        let(:assessment_id) { SecureRandom.uuid }

        it "errors and is shown in apidocs", :show_in_doc do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it_behaves_like "it fails with message", "No such assessment id"
      end
    end

    context "invalid payload" do
      context "missing name on bank account" do
        let(:bank_account_params) { attributes_for_list(:liquid_capital_item, 2).map { |account| account.tap { |item| item.delete(:description) } } }

        it_behaves_like "it fails with message", "Missing parameter description"
      end

      context "missing lowest balance on bank account" do
        let(:bank_account_params) { attributes_for_list(:liquid_capital_item, 2).map { |account| account.tap { |item| item.delete(:value) } } }

        it_behaves_like "it fails with message", "Missing parameter value"
      end

      context "missing description on non_liquid capital" do
        let(:non_liquid_params) { attributes_for_list(:non_liquid_capital_item, 2).map { |nlc| nlc.tap { |item| item.delete(:description) } } }

        it_behaves_like "it fails with message", "Missing parameter description"
      end

      context "missing value on non-liquid capital" do
        let(:non_liquid_params) { attributes_for_list(:non_liquid_capital_item, 2).map { |nlc| nlc.tap { |item| item.delete(:value) } } }

        it_behaves_like "it fails with message", "Missing parameter value"
      end
    end

    def bank_account_params
      [
        {
          description: "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}",
          value: Faker::Number.decimal(r_digits: 2),
        },
        {
          description: "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}",
          value: Faker::Number.decimal(r_digits: 2),
        }
      ]
    end

    def negative_bank_account_params
      [
        {
          description: "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}",
          value: (Faker::Number.decimal(r_digits: 2) * -1),
        },
        {
          description: "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}",
          value: (Faker::Number.decimal(r_digits: 2) * -1),
        }
      ]
    end

    def non_liquid_params
      [
        {
          description: fake_asset_name,
          value: Faker::Number.decimal(r_digits: 2),
        },
        {
          description: fake_asset_name,
          value: Faker::Number.decimal(r_digits: 2),
        }
      ]
    end

    def negative_non_liquid_params
      [
        {
          description: fake_asset_name,
          value: (Faker::Number.decimal(r_digits: 2) * -1),
        },
        {
          description: fake_asset_name,
          value: (Faker::Number.decimal(r_digits: 2) * -1),
        }
      ]
    end

    def fake_asset_name
      [
        "R.J.Ewing Trust",
        "Ming Vase",
        "Van Gogh Sunflowers",
        "Aramco shares",
        "FTSE tracker unit trust",
        "Life Endowment Policy"
      ].sample
    end
  end
end
