require 'rails_helper'

RSpec.describe AssessmentsController, type: :request do
  describe 'POST assessments' do
    let(:params) do
      {
        client_reference_id: 'psr-123',
        submission_date: '2019-06-06',
        matter_proceeding_type: 'domestic_abuse'
      }
    end
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:before_request) { nil }

    subject { post assessments_path, params: params.to_json, headers: headers }

    before do
      before_request
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has a valid payload', :show_in_doc do
      expected_response = {
        success: true,
        objects: [Assessment.last],
        errors: []
      }.to_json
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end

    context 'Active Record Error in service' do
      let(:before_request) do
        creation_service = double Creators::AssessmentCreator, success?: false, errors: ['error creating record']
        allow(Creators::AssessmentCreator).to receive(:call).and_return(creation_service)
      end

      it 'returns http unprocessable_entity' do
        expect(response).to have_http_status(422)
      end

      it 'returns error json payload', :show_in_doc do
        expected_response = {
          errors: ['error creating record'],
          success: false
        }
        expect(parsed_response).to eq expected_response
      end
    end

    context 'invalid matter proceeding type' do
      let(:params) { { matter_proceeding_type: 'xxx', submission_date: '2019-07-01' } }

      it_behaves_like 'it fails with message', %(Invalid parameter 'matter_proceeding_type' value "xxx": Must be one of: <code>domestic_abuse</code>.)
    end

    context 'missing submission date' do
      let(:params) do
        {
          matter_proceeding_type: 'domestic_abuse',
          client_reference_id: 'psr-123'
        }
      end

      it_behaves_like 'it fails with message', 'Missing parameter submission_date'
    end
  end

  describe 'GET /assessments/:id' do
    let(:option) { :below_lower_threshold }

    subject { get assessment_path(assessment), headers: headers }

    context 'no version specified' do
      let(:headers) { { 'Accept' => 'application/json' } }
      context 'passported' do
        let(:assessment) { create :assessment, :passported }

        it 'returns http success', :show_in_doc do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'returns capital summary data as json' do
          subject
          expect(parsed_response).to eq(JSON.parse(Decorators::ResultDecorator.new(assessment.reload).to_json, symbolize_names: true))
        end

        it 'has called the workflow and assessor' do
          expect(Workflows::MainWorkflow).to receive(:call).with(assessment)
          expect(Assessors::MainAssessor).to receive(:call).with(assessment)
          subject
        end
      end

      context 'non-passported' do
        let(:assessment) { create :assessment, :with_everything }
        it 'returns unprocessable entity' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns errors struct with message' do
          subject
          expect(parsed_response[:success]).to be false
          expect(parsed_response[:errors]).to eq ['Version 1 of the API is not able to process un-passported applications']
        end
      end
    end

    context 'version 1 specified in the header' do
      let(:headers) { { 'Accept' => 'application/json;version=1' } }
      let(:assessment) { create :assessment, :passported }

      it 'returns http success', :show_in_doc do
        subject
        expect(response).to have_http_status(:success)
      end

      it 'returns capital summary data as json' do
        subject
        expect(parsed_response).to eq(JSON.parse(Decorators::ResultDecorator.new(assessment.reload).to_json, symbolize_names: true))
      end
    end

    context 'version 2 specifified in the header' do
      let(:headers) { { 'Accept' => 'application/json;version=2' } }

      context 'non-passported application' do
        let(:assessment) { create :assessment, :with_everything }

        it 'returns http success', :show_in_doc do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'returns capital summary data as json' do
          Timecop.freeze do
            subject
            expected_response = Decorators::AssessmentDecorator.new(assessment.reload).as_json.to_json
            expect(parsed_response).to eq(JSON.parse(expected_response, symbolize_names: true))
          end
        end
      end

      context 'passported application' do
        let(:assessment) { create :assessment, :passported }

        it 'returns http success' do
          subject
          expect(response).to have_http_status(:success)
        end

        it 'returns a structure with expected keys' do
          subject
          expect(parsed_response.keys).to eq expected_response_keys
          expect(parsed_response[:assessment].keys).to eq expected_assessment_keys
        end

        it 'returns nil for the income elements of the response' do
          subject
          expect(parsed_response[:assessment][:gross_income]).to be_nil
          expect(parsed_response[:assessment][:disposable_income]).to be_nil
        end
      end
    end

    context 'test assessment NPE6-1' do
      let(:assessment) { create_assessment_npe6_1 }
      let(:headers) { { 'Accept' => 'application/json;version=2' } }

      before { subject }

      it 'returns success' do
        expect(parsed_response[:success]).to be true
      end

      it 'returns expected gross income assessment results' do
        results = parsed_response[:assessment][:gross_income]
        expect(results[:assessment_result]).to eq 'eligible'
        expect(results[:upper_threshold]).to eq 999_999_999_999.0.to_s
        expect(results[:monthly_other_income]).to eq 1415.0.to_s
        expect(results[:monthly_state_benefits]).to eq 216.67.to_s
        expect(results[:total_gross_income]).to eq 1631.67.to_s
      end

      it 'returns expected disposable income results' do
        results = parsed_response[:assessment][:disposable_income]
        expect(results[:childcare_allowance]).to eq 0.0.to_s
        expect(results[:dependant_allowance]).to eq 1457.45.to_s
        expect(results[:maintenance_allowance]).to eq 0.0.to_s
        expect(results[:gross_housing_costs]).to eq 50.0.to_s
        expect(results[:housing_benefit]).to eq 0.0.to_s
        expect(results[:net_housing_costs]).to eq 50.0.to_s
        expect(results[:total_outgoings_and_allowances]).to eq 1507.45.to_s
        expect(results[:total_disposable_income]).to eq 124.22.to_s
        expect(results[:lower_threshold]).to eq 315.0.to_s
        expect(results[:upper_threshold]).to eq 999_999_999_999.0.to_s
        expect(results[:assessment_result]).to eq 'eligible'
        expect(results[:income_contribution]).to eq 0.0.to_s
      end

      it 'returns expected capital results' do
        results = parsed_response[:assessment][:capital]
        main_home = results[:capital_items][:properties][:main_home]
        expect(main_home[:value]).to eq 500_000.0.to_s
        expect(main_home[:outstanding_mortgage]).to eq 150_000.0.to_s
        expect(main_home[:percentage_owned]).to eq 50.0.to_s
        expect(main_home[:shared_with_housing_assoc]).to be false
        expect(main_home[:transaction_allowance]).to eq 15_000.0.to_s
        expect(main_home[:allowable_outstanding_mortgage]).to eq 100_000.0.to_s
        expect(main_home[:net_value]).to eq 385_000.0.to_s
        expect(main_home[:net_equity]).to eq 192_500.0.to_s
        expect(main_home[:main_home_equity_disregard]).to eq 100_000.0.to_s
        expect(main_home[:assessed_equity]).to eq 92_500.0.to_s

        expect(results[:capital_items][:properties][:additional_properties]).to eq []

        expect(results[:total_vehicle]).to eq 9_000.0.to_s
        expect(results[:total_property]).to eq 92_500.0.to_s
        expect(results[:total_mortgage_allowance]).to eq 100_000.0.to_s
        expect(results[:total_capital]).to eq 101_500.0.to_s
        expect(results[:pensioner_capital_disregard]).to eq 100_000.0.to_s
        expect(results[:assessed_capital]).to eq 1_500.0.to_s
        expect(results[:lower_threshold]).to eq 3_000.0.to_s
        expect(results[:upper_threshold]).to eq 999_999_999_999.0.to_s
        expect(results[:assessment_result]).to eq 'eligible'
        expect(results[:capital_contribution]).to eq 0.0.to_s
      end

      it 'returns expected overall results' do
        expect(parsed_response[:assessment][:assessment_result]).to eq 'eligible'
      end
    end

    context 'unknown version' do
      let(:headers) { { 'Accept' => 'application/json;version=9' } }
      let(:assessment) { create :assessment }

      it 'returns unprocessable entity' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors struct with message' do
        subject
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors]).to eq ['Unsupported version specified in AcceptHeader']
      end
    end
  end

  def expected_response_keys
    %i[version timestamp success assessment]
  end

  def expected_assessment_keys
    %i[
      id
      client_reference_id
      submission_date
      matter_proceeding_type
      assessment_result
      applicant
      gross_income
      disposable_income
      capital
    ]
  end

  def create_assessment_npe6_1
    assessment = create :assessment,
                        client_reference_id: 'NPE6-1',
                        submission_date: Date.parse('29/5/2019')
    create :applicant, assessment: assessment, date_of_birth: Date.parse('29/5/1958')
    create_dependant(assessment, '2/2/2005', true, 'child_relative')
    create_dependant(assessment, '5/2/2008', true, 'child_relative')
    create_dependant(assessment, '5/2/2010', true, 'child_relative')
    create_dependant(assessment, '5/2/1989', false, 'adult_relative')
    create_dependant(assessment, '5/2/1987', false, 'adult_relative')

    gis = create :gross_income_summary, assessment: assessment
    ois = create :other_income_source, gross_income_summary: gis, name: 'friends_or_family'
    create :other_income_payment, other_income_source: ois, payment_date: Date.parse('28/2/2019'), amount: 1415
    create :other_income_payment, other_income_source: ois, payment_date: Date.parse('31/3/2019'), amount: 1415
    create :other_income_payment, other_income_source: ois, payment_date: Date.parse('30/4/2019'), amount: 1415

    sbt = create :state_benefit_type, label: 'child_benefit', name: 'Child Benefit', exclude_from_gross_income: false
    sb = create :state_benefit, state_benefit_type: sbt, gross_income_summary: gis
    create :state_benefit_payment, state_benefit: sb, payment_date: Date.parse('1/2/2019'), amount: 200
    create :state_benefit_payment, state_benefit: sb, payment_date: Date.parse('1/3/2019'), amount: 200
    create :state_benefit_payment, state_benefit: sb, payment_date: Date.parse('29/3/2019'), amount: 200

    dis = create :disposable_income_summary, assessment: assessment
    create_mortgage_payment dis, '15/3/2019', 50
    create_mortgage_payment dis, '15/4/2019', 50
    create_mortgage_payment dis, '15/5/2019', 50

    create_childcare_payment dis, '15/3/2019', 100
    create_childcare_payment dis, '15/4/2019', 100
    create_childcare_payment dis, '15/5/2019', 100

    cs = create :capital_summary, assessment: assessment
    create_main_home cs, true, 500_000, 150_000, 50, false
    create :liquid_capital_item, capital_summary: cs, description: 'Bank acct 1', value: 0
    create :liquid_capital_item, capital_summary: cs, description: 'Bank acct 2', value: 0
    create :liquid_capital_item, capital_summary: cs, description: 'Bank acct 3', value: 0
    create :vehicle, capital_summary: cs, value: 9_000, loan_amount_outstanding: 0, date_of_purchase: Date.parse('20/5/2018'), in_regular_use: false
    assessment
  end

  def create_childcare_payment(dis, date, amount)
    create :childcare_outgoing,
           disposable_income_summary: dis,
           payment_date: Date.parse(date),
           amount: amount
  end

  def create_dependant(assessment, dob, education, relationship)
    create :dependant,
           assessment: assessment,
           date_of_birth: Date.parse(dob),
           in_full_time_education: education,
           monthly_income: 0,
           relationship: relationship
  end

  def create_mortgage_payment(dis, date, amount)
    create :housing_cost_outgoing,
           disposable_income_summary: dis,
           housing_cost_type: 'mortgage',
           payment_date: Date.parse(date),
           amount: amount
  end

  def create_main_home(capital_summary, main_home, value, mortgage, percentage_owned, housing_assoc)
    create :property,
           capital_summary: capital_summary,
           main_home: main_home,
           value: value,
           outstanding_mortgage: mortgage,
           percentage_owned: percentage_owned,
           shared_with_housing_assoc: housing_assoc
  end
end
