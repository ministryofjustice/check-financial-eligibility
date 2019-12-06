require 'rails_helper'

RSpec.describe EarnedIncomesController, type: :request do
  describe 'POST earned_income' do
    let(:assessment) { create :assessment }
    let(:assessment_id) { assessment.id }
    let(:params) do
      {
        employments: employments_params
      }
    end
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    subject { post assessment_earned_incomes_path(assessment_id), params: params.to_json, headers: headers }

    before { subject }

    context 'valid payload' do
      context 'with both types of income' do
        it 'returns http success', :show_in_doc do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end

        it 'creates an employment record' do
          expect(Employment.count).to eq 1
        end

        it 'creates three wage_payments records' do
          expect(WagePayment.count).to eq 3
        end

        it 'creates two benefit_in_kind records' do
          expect(BenefitInKind.count).to eq 2
        end
      end

      context 'with only wage payments' do
        let(:params) do
          {
            employments: employments_wage_only_params
          }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end

        it 'creates an employment record' do
          expect(Employment.count).to eq 1
        end

        it 'creates three wage_payments records' do
          expect(WagePayment.count).to eq 3
        end

        it 'creates no benefit_in_kind records' do
          expect(BenefitInKind.count).to eq 0
        end
      end

      context 'with multiple employments' do
        let(:params) do
          {
            employments: multi_employments_params
          }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
        end

        it 'creates two employment records' do
          expect(Employment.count).to eq 2
        end

        it 'creates six wage_payments records' do
          expect(WagePayment.count).to eq 6
        end

        it 'creates four benefit_in_kind records' do
          expect(BenefitInKind.count).to eq 4
        end
      end

      context 'empty payload' do
        let(:params) { {} }

        it 'returns http unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error payload' do
          expect(parsed_response[:success]).to eq false
          expect(parsed_response[:errors]).to eq ['Missing parameter employments']
        end
      end

      context 'Active Record error' do
        let(:assessment_id) { SecureRandom.uuid }

        it 'errors and is shown in apidocs', :show_in_doc do
          expect(response).to have_http_status(422)
        end

        it_behaves_like 'it fails with message', 'No such assessment id'
      end
    end

    context 'invalid payload' do
      context 'missing name on employment' do
        let(:employments_params) { employments_no_name_params }
        it_behaves_like 'it fails with message', 'Missing parameter name'
      end

      context 'no wage payments' do
        let(:employments_params) { employments_no_wages_params }
        it_behaves_like 'it fails with message', 'Missing parameter wages'
      end

      xcontext 'empty wage payments array' do # TODO: get validation working to reject an empty wages array
        let(:employments_params) { employments_empty_wages_array_params }
        it_behaves_like 'it fails with message', 'Missing parameter wage_payments'
      end

      context 'missing date on wage payment' do
        let(:employments_params) { employments_no_date_params }
        it_behaves_like 'it fails with message', 'Missing parameter date'
      end

      xcontext 'date on wage payment is before calculation period' do # TODO: get validation working to reject wages with dates before the assessment submission date
        let(:employments_params) { employments_date_before_params }
        it_behaves_like 'it fails with message', "Invalid parameter 'date' value \"1900-11-01\": Invalid wage date"
      end

      context 'date on wage payment is in the future' do
        let(:employments_params) { employments_date_after_params }
        it_behaves_like 'it fails with message', "Invalid parameter 'date' value \"2200-11-01\": Invalid wage date"
      end
    end

    def employments_params
      [
        {
          "name": 'Employer name or reference',
          "wages": [
            {
              "date": '2019-11-01',
              "gross_payment": 1046.44
            },
            {
              "date": '2019-10-01',
              "gross_payment": 1034.33
            },
            {
              "date": '2019-09-01',
              "gross_payment": 1033.44
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values":
              [
                "company_car": 566.00,
                "health_insurance": 244.02
              ]
          }
        }
      ]
    end

    def employments_no_name_params
      [
        {
          "wages": [
            {
              "date": '2019-11-01',
              "gross_payment": 1046.44
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values": []
          }
        }
      ]
    end

    def employments_no_date_params
      [
        {
          "name": 'Employer name or reference',
          "wages": [
            {
              "gross_payment": 1046.44
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values": []
          }
        }
      ]
    end

    def employments_date_before_params
      [
        {
          "name": 'Employer name or reference',
          "wages": [
            {
              "date": '1900-11-01',
              "gross_payment": 1046.44
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values": []
          }
        }
      ]
    end

    def employments_date_after_params
      [
        {
          "name": 'Employer name or reference',
          "wages": [
            {
              "date": '2200-11-01',
              "gross_payment": 1046.44
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values": []
          }
        }
      ]
    end

    def employments_wage_only_params
      [
        {
          "name": 'Employer name or reference',
          "wages": [
            {
              "date": '2019-11-01',
              "gross_payment": 1046.44
            },
            {
              "date": '2019-10-01',
              "gross_payment": 1034.33
            },
            {
              "date": '2019-09-01',
              "gross_payment": 1033.44
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values": []
          }
        }
      ]
    end

    def employments_no_wages_params
      [
        {
          "name": 'Employer name or reference',
          "benefits_in_kind": {
            "monthly_taxable_values":
              [
                "company_car": 566.00,
                "health_insurance": 244.02
              ]
          }
        }
      ]
    end

    def employments_empty_wages_array_params
      [
        {
          "name": 'Employer name or reference',
          "wages": [],
          "benefits_in_kind": {
            "monthly_taxable_values":
              [
                "company_car": 566.00,
                "health_insurance": 244.02
              ]
          }
        }
      ]
    end

    def multi_employments_params
      [
        {
          "name": 'Employer 1',
          "wages": [
            {
              "date": '2019-11-01',
              "gross_payment": 1.11
            },
            {
              "date": '2019-10-01',
              "gross_payment": 1.11
            },
            {
              "date": '2019-09-01',
              "gross_payment": 1.11
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values":
              [
                "company_car": 1.11,
                "health_insurance": 1.11
              ]
          }
        },
        {
          "name": 'Employer 2',
          "wages": [
            {
              "date": '2019-11-01',
              "gross_payment": 2.22
            },
            {
              "date": '2019-10-01',
              "gross_payment": 2.22
            },
            {
              "date": '2019-09-01',
              "gross_payment": 2.22
            }
          ],
          "benefits_in_kind": {
            "monthly_taxable_values":
              [
                "company_car": 2.22,
                "health_insurance": 2.22
              ]
          }
        }
      ]
    end
  end
end
