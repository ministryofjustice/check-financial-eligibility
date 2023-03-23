require "rails_helper"

RSpec.describe CashTransactionsController, type: :request do
  describe "POST cash_transactions" do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:creator_class) { Creators::CashTransactionsCreator }
    let(:creator_instance) { instance_double(creator_class) }
    let(:month1) { Date.current.beginning_of_month - 3.months }
    let(:month2) { Date.current.beginning_of_month - 2.months }
    let(:month3) { Date.current.beginning_of_month - 1.month }

    subject(:post_payload) { post assessment_cash_transactions_path(assessment_id), params: params.to_json, headers: }

    context "valid payload" do
      let(:params) { valid_params }

      it "returns http success" do
        post_payload
        expect(response).to have_http_status(:success)
      end

      it "calls cash transactions creator" do
        allow(creator_instance).to receive(:success?).and_return(true)
        allow(creator_class)
          .to receive(:call)
               .with(assessment_id:, cash_transaction_params: params).and_return(creator_instance)
        post_payload
        expect(response).to have_http_status(:success)
      end

      context "creation is valid" do
        let(:creator_service) { instance_double Creators::CashTransactionsCreator, success?: true }

        before do
          allow(creator_class).to receive(:call).and_return(creator_service)
          post_payload
        end

        it "returns a success response body" do
          expect(parsed_response[:success]).to be true
          expect(parsed_response[:errors]).to be_empty
        end

        it "returns successful http response" do
          expect(response.status).to eq 200
        end
      end

      context "creation is invalid" do
        let(:creator_service) { instance_double Creators::CashTransactionsCreator, success?: false, errors: ["error 1", "error 2"] }

        before do
          allow(creator_class).to receive(:call).and_return(creator_service)
          post_payload
        end

        it "returns a error response" do
          expect(parsed_response).to eq(success: false, errors: ["error 1", "error 2"])
        end

        it "returns unprocessable response" do
          expect(response.status).to eq 422
        end
      end
    end

    context "invalid payload" do
      context "invalid income" do
        context "missing category" do
          let(:params) { missing_income_category_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/income\/0' did not contain a required property of 'category'/
        end

        context "missing payments" do
          let(:params) { missing_income_payment_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/income\/0' did not contain a required property of 'payments'/
        end

        context "invalid category" do
          let(:params) { invalid_income_category_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/income\/0\/category' value "xxxx" did not match one of the following values/
        end

        context "negative amounts" do
          let(:params) { negative_income_amount_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/income\/1\/payments\/2\/amount' value "-100.00" did not match the regex/
        end

        context "missing amount" do
          let(:params) { missing_income_amount_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/income\/1\/payments\/2' did not contain a required property of 'amount'/
        end

        context "non-number amount" do
          let(:params) { non_number_income_amount_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/income\/1\/payments\/2\/amount' value "hello" did not match the regex/
        end
      end

      context "invalid outgoings" do
        context "missing category" do
          let(:params) { missing_outgoings_category_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/outgoings\/0' did not contain a required property of 'category'/
        end

        context "invalid category" do
          let(:params) { invalid_outgoings_category_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/outgoings\/0\/category' value "xxxx" did not match one of the following values/
        end

        context "missing payments" do
          let(:params) { missing_outgoings_payments_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/outgoings\/0' did not contain a required property of 'payments'/
        end

        context "negative payment amount" do
          let(:params) { negative_outgoings_payment_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/outgoings\/1\/payments\/2\/amount' value "-100.00" did not match the regex/
        end

        context "missing payment amount" do
          let(:params) { missing_outgoings_payment_amount_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/outgoings\/1\/payments\/2' did not contain a required property of 'amount'/
        end

        context "invalid payment amount value" do
          let(:params) { invalid_outgoings_payment_params }

          before { post_payload }

          it_behaves_like "it fails with message",
                          /The property '#\/outgoings\/1\/payments\/2\/amount' value "hello" did not match the regex/
        end
      end
    end

    def valid_params
      {
        income: [
          {
            category: "maintenance_in",
            payments: [
              {
                date: month1.strftime("%F"),
                amount: 1046.44,
                client_id: "05459c0f-a620-4743-9f0c-b3daa93e5711",
              },
              {
                date: month2.strftime("%F"),
                amount: 1034.33,
                client_id: "10318f7b-289a-4fa5-a986-fc6f499fecd0",
              },
              {
                date: month3.strftime("%F"),
                amount: 1033.44,
                client_id: "5cf62a12-c92b-4cc1-b8ca-eeb4efbcce21",
              },
            ],
          },
          {
            category: "friends_or_family",
            payments: [
              {
                date: month2.strftime("%F"),
                amount: 250.0,
                client_id: "e47b707b-d795-47c2-8b39-ccf022eae33b",
              },
              {
                date: month3.strftime("%F"),
                amount: 266.02,
                client_id: "b0c46cc7-8478-4658-a7f9-85ec85d420b1",
              },
              {
                date: month1.strftime("%F"),
                amount: 250.0,
                client_id: "f3ec68a3-8748-4ed5-971a-94d133e0efa0",
              },
            ],
          },
        ],
        outgoings:
          [
            {
              category: "maintenance_out",
              payments: [
                {
                  date: month2.strftime("%F"),
                  amount: 256.0,
                  client_id: "347b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month3.strftime("%F"),
                  amount: 256.0,
                  client_id: "722b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month1.strftime("%F"),
                  amount: 256.0,
                  client_id: "abcb707b-d795-47c2-8b39-ccf022eae33b",
                },
              ],
            },
            {
              category: "child_care",
              payments: [
                {
                  date: month3.strftime("%F"),
                  amount: 258.0,
                  client_id: "ff7b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month2.strftime("%F"),
                  amount: 257.0,
                  client_id: "ee7b707b-d795-47c2-8b39-ccf022eae33b",
                },
                {
                  date: month1.strftime("%F"),
                  amount: 256.0,
                  client_id: "ec7b707b-d795-47c2-8b39-ccf022eae33b",
                },
              ],
            },
          ],
      }
    end

    def invalid_income_category_params
      params = valid_params.clone
      params[:income].first[:category] = "xxxx"
      params
    end

    def missing_income_category_params
      params = valid_params.clone
      params[:income][0].delete(:category)
      params
    end

    def missing_income_payment_params
      params = valid_params.clone
      params[:income][0].delete(:payments)
      params
    end

    def negative_income_amount_params
      params = valid_params.clone
      params[:income].last[:payments].last[:amount] = "-100.00"
      params
    end

    def missing_income_amount_params
      params = valid_params.clone
      params[:income].last[:payments].last.delete(:amount)
      params
    end

    def non_number_income_amount_params
      params = valid_params.clone
      params[:income].last[:payments].last[:amount] = "hello"
      params
    end

    def negative_outgoings_amount_params
      params = valid_params.clone
      params[:outgoings].last[:payments].last[:amount] = "-100.00"
      params
    end

    def missing_outgoings_category_params
      params = valid_params.clone
      params[:outgoings][0].delete(:category)
      params
    end

    def missing_outgoings_payments_params
      params = valid_params.clone
      params[:outgoings][0].delete(:payments)
      params
    end

    def invalid_outgoings_category_params
      params = valid_params.clone
      params[:outgoings].first[:category] = "xxxx"
      params
    end

    def negative_outgoings_payment_params
      params = valid_params.clone
      params[:outgoings].last[:payments].last[:amount] = "-100.00"
      params
    end

    def missing_outgoings_payment_amount_params
      params = valid_params.clone
      params[:outgoings].last[:payments].last.delete(:amount)
      params
    end

    def invalid_outgoings_payment_params
      params = valid_params.clone
      params[:outgoings].last[:payments].last[:amount] = "hello"
      params
    end
  end
end
