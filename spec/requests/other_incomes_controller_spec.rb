require "rails_helper"

UUID_REGEX = /^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$/

RSpec.describe OtherIncomesController, type: :request do
  describe "POST other_income" do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:params) { other_income_params  }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    subject(:post_payload) { post assessment_other_incomes_path(assessment_id), params: params.to_json, headers: }

    context "with valid payload" do
      context "with two sources" do
        it "returns http success" do
          post_payload
          expect(response).to have_http_status(:success)
        end

        it "creates two other income source records" do
          expect { post_payload }.to change { gross_income_summary.other_income_sources.count }.by(2)
          sources = gross_income_summary.other_income_sources.order(:name)
          expect(sources.first.name).to eq "friends_or_family"
          expect(sources.last.name).to eq "maintenance_in"
        end

        it "creates the required number of OtherIncomePayment record for each source" do
          expect { post_payload }.to change(OtherIncomePayment, :count).by(6)
          source = gross_income_summary.other_income_sources.order(:name).first
          expect(source.other_income_payments.count).to eq 3
          payments = source.other_income_payments.order(:payment_date)

          expect(payments[0].payment_date).to eq Date.new(2019, 9, 1)
          expect(payments[0].amount).to eq 250.00
          expect(payments[0].client_id).to match UUID_REGEX

          expect(payments[1].payment_date).to eq Date.new(2019, 10, 1)
          expect(payments[1].amount).to eq 266.02
          expect(payments[1].client_id).to match UUID_REGEX

          expect(payments[2].payment_date).to eq Date.new(2019, 11, 1)
          expect(payments[2].amount).to eq 250.00
          expect(payments[2].client_id).to match UUID_REGEX
        end

        it "creates records with client id where specified" do
          post_payload
          source = gross_income_summary.other_income_sources.order(:name).last
          source.other_income_payments.each do |rec|
            expect(rec.client_id).to match UUID_REGEX
          end
        end

        it "generates a valid response" do
          post_payload
          expect(parsed_response[:success]).to eq true
          expect(parsed_response[:errors]).to be_empty
        end
      end
    end

    context "with invalid_payload" do
      context "missing source in the second element" do
        let(:params) do
          new_hash = other_income_params
          new_hash[:other_incomes].last.delete(:source)
          new_hash
        end

        it "returns unsuccessful" do
          post_payload
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response).to match(errors: [/The property '#\/other_incomes\/1' did not contain a required property of 'source' in schema file/], success: false)
        end

        it "does not create any other income source records" do
          expect { post_payload }.not_to change(OtherIncomeSource, :count)
        end

        it "does not create any other income payment records" do
          expect { post_payload }.not_to change(OtherIncomePayment, :count)
        end
      end

      context "missing required parameter client_id" do
        let(:params) do
          new_hash = other_income_params
          new_hash[:other_incomes].last[:payments].first.delete(:client_id)
          new_hash
        end

        it "returns unsuccessful" do
          post_payload
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response).to match(errors: [/The property '#\/other_incomes\/1\/payments\/0' did not contain a required property of 'client_id' in schema file/], success: false)
        end

        it "does not create any other income source records" do
          expect { post_payload }.not_to change(OtherIncomeSource, :count)
        end

        it "does not create any other income payment records" do
          expect { post_payload }.not_to change(OtherIncomePayment, :count)
        end
      end

      context "with invalid source" do
        let(:params) do
          new_hash = other_income_params
          new_hash[:other_incomes].last[:source] = "imagined_source"
          new_hash
        end

        it "returns unsuccessful" do
          post_payload
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response[:success]).to be false
        end

        it "contains an error message" do
          post_payload
          expect(parsed_response[:errors].first).to match(/The property '#\/other_incomes\/1\/source' value "imagined_source" did not match one of the following values: benefits, friends_or_family, maintenance_in, property_or_lodger, pension, Benefits, Friends or family, Maintenance in, Property or lodger, Pension in schema file/)
        end
      end
    end

    context "with invalid_assessment_id" do
      let(:assessment_id) { SecureRandom.uuid }

      it "returns unsuccessful" do
        post_payload
        expect(response.status).to eq 422
      end

      it "contains success false in the response body" do
        post_payload
        expect(parsed_response).to eq(errors: ["No such assessment id"], success: false)
      end
    end

    context "with missing payment date" do
      let(:assessment_id) { SecureRandom.uuid }
      let(:other_income_params) do
        {
          other_incomes: [
            {
              source: "maintenance_in",
              payments: [
                {
                  amount: 1046.44,
                  client_id: SecureRandom.uuid,
                },
              ],
            },
          ],
        }
      end

      it "returns unsuccessful" do
        post_payload
        expect(response.status).to eq 422
      end

      it "contains success false in the response body" do
        post_payload
        expect(parsed_response).to match(errors: [/The property '#\/other_incomes\/0\/payments\/0' did not contain a required property of 'date' in schema file/], success: false)
      end
    end

    context "with invalid client_id" do
      let(:assessment_id) { SecureRandom.uuid }
      let(:other_income_params) do
        {
          other_incomes: [
            {
              source: "maintenance_in",
              payments: [
                {
                  date: "2019-11-01",
                  amount: 1046.44,
                  client_id: 1,
                },
              ],
            },
          ],
        }
      end

      it "returns unsuccessful" do
        post_payload
        expect(response.status).to eq 422
      end

      it "contains success false in the response body" do
        post_payload
        expect(parsed_response).to match(errors: [/The property '#\/other_incomes\/0\/payments\/0\/client_id' of type integer did not match the following type: string in schema file/], success: false)
      end
    end

    def other_income_params
      {
        other_incomes: [
          {
            source: "maintenance_in",
            payments: [
              {
                date: "2019-11-01",
                amount: 1046.44,
                client_id: SecureRandom.uuid,
              },
              {
                date: "2019-10-01",
                amount: 1034.33,
                client_id: SecureRandom.uuid,
              },
              {
                date: "2019-09-01",
                amount: 1033.44,
                client_id: SecureRandom.uuid,
              },
            ],
          },
          {
            source: "friends_or_family",
            payments: [
              {
                date: "2019-11-01",
                amount: 250.00,
                client_id: SecureRandom.uuid,
              },
              {
                date: "2019-10-01",
                amount: 266.02,
                client_id: SecureRandom.uuid,
              },
              {
                date: "2019-09-01",
                amount: 250.00,
                client_id: SecureRandom.uuid,
              },
            ],
          },
        ],
      }
    end
  end
end
