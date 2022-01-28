require "rails_helper"

RSpec.describe AssessmentsController, type: :request do
  before do
    create :bank_holiday
    mock_lfa_responses
  end

  describe "POST assessments" do
    let(:ipaddr) { "127.0.0.1" }
    let(:ccms_codes) { %w[DA005 SE003 SE014] }

    context "version 3" do
      let(:params) do
        {
          client_reference_id: "psr-123",
          submission_date: "2019-06-06",
          matter_proceeding_type: "domestic_abuse",
        }
      end
      let(:headers) { { "CONTENT_TYPE" => "application/json" } }
      let(:before_request) { nil }

      subject { post assessments_path, params: params.to_json, headers: headers }

      before do
        before_request
        subject
      end

      it "returns http success", :show_in_doc do
        expect(response).to have_http_status(:success)
      end

      it "has a valid payload", :show_in_doc, doc_title: "POST Success Response" do
        expected_response = {
          success: true,
          assessment_id: Assessment.last.id,
          errors: [],
        }.to_json
        expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
      end

      context "Active Record Error in service" do
        let(:before_request) do
          creation_service = instance_double Creators::AssessmentCreator, success?: false, errors: ['error creating record']
          allow(Creators::AssessmentCreator).to receive(:call).and_return(creation_service)
        end

        it 'returns http unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error json payload", :show_in_doc, doc_title: "POST Error Response" do
          expected_response = {
            success: false,
            errors: ["error creating record"],
          }
          expect(parsed_response).to eq expected_response
        end
      end

      context "invalid matter proceeding type" do
        let(:params) { { matter_proceeding_type: "xxx", submission_date: "2019-07-01" } }

        it_behaves_like "it fails with message", %(Invalid parameter 'matter_proceeding_type' value "xxx": Must be one of: <code>domestic_abuse</code>.)
      end

      context "missing submission date" do
        let(:params) do
          {
            matter_proceeding_type: "domestic_abuse",
            client_reference_id: "psr-123",
          }
        end

        it_behaves_like "it fails with message", "Missing parameter submission_date"
      end
    end

    context "version 4" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json",
          "Accept" => "application/json; version=4",
        }
      end
      let(:params) do
        {
          client_reference_id: "psr-123",
          submission_date: "2019-06-06",
          proceeding_types: {
            ccms_codes:,
          },
        }
      end

      it "calls the assessment creator with version and params" do
        expect(Creators::AssessmentCreator).to receive(:call).with(remote_ip: ipaddr, raw_post: params.to_json, version: "4").and_call_original
        post assessments_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
        expect(parsed_response[:success]).to be true
      end
    end

    context "invalid version" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json",
          "Accept" => "application/json; version=5",
        }
      end
      let(:params) do
        {
          client_reference_id: "psr-123",
          submission_date: "2019-06-06",
          proceeding_types: {
            ccms_codes:,
          },
        }
      end

      it "returns error" do
        post assessments_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors]).to eq ["Version not valid in Accept header"]
      end
    end
  end

  describe "GET /assessments/:id" do
    let(:option) { :below_lower_threshold }
    let(:now) { Time.zone.now }

    subject { get assessment_path(assessment), headers: headers }

    context "calling the correct workflows assessors and decorators" do
      before do
        allow(Assessment).to receive(:find).with(assessment.id.to_s).and_return(assessment)
        allow(Workflows::MainWorkflow).to receive(:call).with(assessment)
        allow(Assessors::MainAssessor).to receive(:call).with(assessment)
        allow(assessment).to receive(:version_3?).and_return(is_version3)
      end

      let(:assessment) { create :assessment, :passported, :with_everything, :with_eligibilities }

      context "version 3" do
        let(:is_version3) { true }
        let(:decorator) { instance_double Decorators::V3::AssessmentDecorator }

<<<<<<< HEAD:spec/requests/assessments_spec.rb
        it "calls the required services and uses the V3 decorator" do
          expect(Decorators::V3::AssessmentDecorator).to receive(:new).with(assessment).and_return(decorator)
          expect(decorator).to receive(:as_json).and_return("")
=======
        it 'calls the required services and uses the V3 decorator' do
          allow(Decorators::V3::AssessmentDecorator).to receive(:new).with(assessment).and_return(decorator)
          allow(decorator).to receive(:as_json).and_return('')
>>>>>>> 330cbae (fix cop RSpec/FilePath and failures arising from those files now being linted):spec/requests/assessments_controller_spec.rb

          subject
        end
      end

      context "version 4" do
        let(:is_version3) { false }
        let(:decorator) { instance_double Decorators::V4::AssessmentDecorator }

<<<<<<< HEAD:spec/requests/assessments_spec.rb
        it "calls the required services and uses the V3 decorator" do
          expect(Decorators::V4::AssessmentDecorator).to receive(:new).with(assessment).and_return(decorator)
          expect(decorator).to receive(:as_json).and_return("")
=======
        it 'calls the required services and uses the V3 decorator' do
          allow(Decorators::V4::AssessmentDecorator).to receive(:new).with(assessment).and_return(decorator)
          allow(decorator).to receive(:as_json).and_return('')
>>>>>>> 330cbae (fix cop RSpec/FilePath and failures arising from those files now being linted):spec/requests/assessments_controller_spec.rb

          subject
        end
      end
    end

    context "untrapped error during processing" do
      let(:assessment) { create :assessment, :with_everything, :with_eligibilities }

      it "call sentry and returns error response" do
        allow(Assessors::MainAssessor).to receive(:call).and_raise(RuntimeError, "Oops")
        expect(Sentry).to receive(:capture_exception)
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors].first).to match(/^RuntimeError: Oops/)
      end
    end

    context "test assessment NPE6-1" do
      let(:assessment) { create_assessment_npe61 }

      context "VERSION 3" do
        before { subject }

        let(:headers) { { "Accept" => "application/json;version=3" } }

        it "returns success" do
          expect(parsed_response[:success]).to be true
        end

        it "returns expected gross income assessment results" do
          results = parsed_response[:assessment][:gross_income]
          expect(results[:summary][:assessment_result]).to eq "eligible"
          expect(results[:summary][:upper_threshold]).to eq 999_999_999_999.0.to_s
          expect(results[:state_benefits][:monthly_equivalents][:all_sources]).to eq 200.0.to_s
          expect(results[:summary][:total_gross_income]).to eq 1615.0.to_s
        end

        it "returns expected gross income monthly equivalents" do
          mie = parsed_response[:assessment][:gross_income][:other_income][:monthly_equivalents][:all_sources]
          expect(mie[:friends_or_family]).to eq 1415.0.to_s
          expect(mie[:maintenance_in]).to eq 0.0.to_s
          expect(mie[:property_or_lodger]).to eq 0.0.to_s
        end

        it "returns expected gross income student loan amount" do
          mie = parsed_response[:assessment][:gross_income][:irregular_income][:monthly_equivalents]
          expect(mie[:student_loan]).to eq 0.0.to_s
        end

        it "returns expected disposable income monthly equivalents" do
          moe = parsed_response[:assessment][:disposable_income][:monthly_equivalents][:all_sources]
          expect(moe[:child_care]).to eq 0.0.to_s
          expect(moe[:maintenance_out]).to eq 0.0.to_s
          expect(moe[:rent_or_mortgage]).to eq 50.0.to_s
          expect(moe[:legal_aid]).to eq 0.0.to_s
        end

        it "returns expected disposable income results" do
          results = parsed_response[:assessment][:disposable_income]
          expect(results[:childcare_allowance]).to eq 0.0.to_s
          expect(results[:dependant_allowance]).to eq 1457.45.to_s
          expect(results[:maintenance_allowance]).to eq 0.0.to_s
          expect(results[:gross_housing_costs]).to eq 50.0.to_s
          expect(results[:housing_benefit]).to eq 0.0.to_s
          expect(results[:net_housing_costs]).to eq 50.0.to_s
          expect(results[:total_outgoings_and_allowances]).to eq 1507.45.to_s
          expect(results[:total_disposable_income]).to eq 107.55.to_s
          expect(results[:lower_threshold]).to eq 315.0.to_s
          expect(results[:upper_threshold]).to eq 999_999_999_999.0.to_s
          expect(results[:assessment_result]).to eq "eligible"
          expect(results[:income_contribution]).to eq 0.0.to_s
        end

        it "returns expected capital results", :show_in_doc, doc_title: "GET Version 3 Non-Passported Response" do
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
          expect(results[:pensioner_capital_disregard]).to eq 60_000.0.to_s
          expect(results[:assessed_capital]).to eq 41_500.0.to_s
          expect(results[:lower_threshold]).to eq 3_000.0.to_s
          expect(results[:upper_threshold]).to eq 999_999_999_999.0.to_s
          expect(results[:assessment_result]).to eq "contribution_required"
          expect(results[:capital_contribution]).to eq 38_500.0.to_s
        end

        it "returns expected overall results" do
          expect(parsed_response[:assessment][:assessment_result]).to eq "contribution_required"
        end
      end

      context "version 4" do
        before do
          assessment.update!(version: "4")
          travel_to frozen_time
          subject
          travel_back
        end

        let(:headers) { { "Accept" => "application/json;version=4" } }
        let(:frozen_time) { Time.zone.now }

        it "returns expected structure", :show_in_doc, doc_title: "POST V4 Success Response" do
          expect(parsed_response).to eq expected_v4_result
        end
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
      remarks
    ]
  end

  def create_assessment_npe61
    assessment = create :assessment,
                        client_reference_id: "NPE6-1",
                        submission_date: Date.parse("29/5/2019")
    create :applicant, assessment:, date_of_birth: Date.parse("29/5/1958")
    create_dependant(assessment, "2/2/2005", true, "child_relative")
    create_dependant(assessment, "5/2/2008", true, "child_relative")
    create_dependant(assessment, "5/2/2010", true, "child_relative")
    create_dependant(assessment, "5/2/1989", false, "adult_relative")
    create_dependant(assessment, "5/2/1987", false, "adult_relative")

    gis = create :gross_income_summary, assessment: assessment
    ois = create :other_income_source, gross_income_summary: gis, name: "friends_or_family"
    create :other_income_payment, other_income_source: ois, payment_date: Date.parse("28/2/2019"), amount: 1415, client_id: SecureRandom.uuid
    create :other_income_payment, other_income_source: ois, payment_date: Date.parse("31/3/2019"), amount: 1415, client_id: SecureRandom.uuid
    create :other_income_payment, other_income_source: ois, payment_date: Date.parse("30/4/2019"), amount: 1415, client_id: SecureRandom.uuid

    sbt = create :state_benefit_type, label: "child_benefit", name: "Child Benefit", exclude_from_gross_income: false
    sb = create :state_benefit, state_benefit_type: sbt, gross_income_summary: gis
    create :state_benefit_payment, state_benefit: sb, payment_date: Date.parse("1/2/2019"), amount: 200, client_id: SecureRandom.uuid
    create :state_benefit_payment, state_benefit: sb, payment_date: Date.parse("10/3/2019"), amount: 202, client_id: SecureRandom.uuid
    create :state_benefit_payment, state_benefit: sb, payment_date: Date.parse("29/3/2019"), amount: 198, client_id: SecureRandom.uuid

    dis = create :disposable_income_summary, assessment: assessment
    create_mortgage_payment dis, "15/3/2019", 50
    create_mortgage_payment dis, "15/4/2019", 50
    create_mortgage_payment dis, "15/5/2019", 50

    create_childcare_payment dis, "15/3/2019", 100
    create_childcare_payment dis, "15/4/2019", 100
    create_childcare_payment dis, "15/5/2019", 100

    cs = create :capital_summary, assessment: assessment
    create_main_home cs, true, 500_000, 150_000, 50, false
    create :liquid_capital_item, capital_summary: cs, description: "Bank acct 1", value: 0
    create :liquid_capital_item, capital_summary: cs, description: "Bank acct 2", value: 0
    create :liquid_capital_item, capital_summary: cs, description: "Bank acct 3", value: 0
    create :vehicle, capital_summary: cs, value: 9_000, loan_amount_outstanding: 0, date_of_purchase: Date.parse("20/5/2018"), in_regular_use: false

    create :capital_eligibility, capital_summary: cs, proceeding_type_code: assessment.proceeding_type_codes.first
    create :gross_income_eligibility, gross_income_summary: gis, proceeding_type_code: assessment.proceeding_type_codes.first
    create :disposable_income_eligibility, disposable_income_summary: dis, proceeding_type_code: assessment.proceeding_type_codes.first
    create :assessment_eligibility, assessment:, proceeding_type_code: assessment.proceeding_type_codes.first

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
           housing_cost_type: "mortgage",
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

  def expected_v4_result
    client_ids = StateBenefitPayment.order(:payment_date).map(&:client_id)
    {
      version: "4",
      timestamp: frozen_time.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
      success: true,
      result_summary: {
        overall_result: {
          result: "contribution_required",
          capital_contribution: 38_500.0,
          income_contribution: 0.0,
          matter_types: [
            {
              matter_type: "domestic_abuse",
              result: "contribution_required",
            }
          ],
          proceeding_types: [
            {
              ccms_code: "DA001",
              result: "contribution_required",
            }
          ],
        },
        gross_income: {
          total_gross_income: 1615.0,
          proceeding_types: [
            {
              ccms_code: "DA001",
              upper_threshold: 999_999_999_999.0,
              result: "eligible",
            }
          ],
        },
        disposable_income: {
          dependant_allowance: 1457.45,
          gross_housing_costs: 50.0,
          housing_benefit: 0.0,
          net_housing_costs: 50.0,
          maintenance_allowance: 0.0,
          total_outgoings_and_allowances: 1507.45,
          total_disposable_income: 107.55,
          employment_income:
            {
              gross_income: 0.0,
              benefits_in_kind: 0.0,
              tax: 0.0,
              national_insurance: 0.0,
              fixed_employment_deduction: 0.0,
              net_employment_income: 0.0,
            },
          income_contribution: 0.0,
          proceeding_types: [
            {
              ccms_code: "DA001",
              upper_threshold: 999_999_999_999.0,
              lower_threshold: 315.0,
              result: "eligible",
            }
          ],
        },
        capital: {
          total_liquid: 0.0,
          total_non_liquid: 0.0,
          total_vehicle: 9000.0,
          total_property: 92_500.0,
          total_mortgage_allowance: 100_000.0,
          total_capital: 101_500.0,
          pensioner_capital_disregard: 60_000.0,
          capital_contribution: 38_500.0,
          assessed_capital: 41_500.0,
          proceeding_types: [
            {
              ccms_code: "DA001",
              lower_threshold: 3000.0,
              upper_threshold: 999_999_999_999.0,
              result: "contribution_required",
            }
          ],
        },
      },
      assessment: {
        id: assessment.id,
        client_reference_id: "NPE6-1",
        submission_date: "2019-05-29",
        applicant: {
          date_of_birth: "1958-05-29",
          involvement_type: "applicant",
          has_partner_opponent: false,
          receives_qualifying_benefit: false,
          self_employed: false,
        },
        gross_income: {
          employment_income: [],
          irregular_income: {
            monthly_equivalents: {
              student_loan: 0.0,
            },
          },
          state_benefits: {
            monthly_equivalents: {
              all_sources: 200.0,
              cash_transactions: 0.0,
              bank_transactions: [
                {
                  name: "Child Benefit",
                  monthly_value: 200.0,
                  excluded_from_income_assessment: false,
                }
              ],
            },
          },
          other_income: {
            monthly_equivalents: {
              all_sources: {
                friends_or_family: 1415.0,
                maintenance_in: 0.0,
                property_or_lodger: 0.0,
                pension: 0.0,
              },
              bank_transactions: {
                friends_or_family: 1415.0,
                maintenance_in: 0.0,
                property_or_lodger: 0.0,
                pension: 0.0,
              },
              cash_transactions: {
                friends_or_family: 0.0,
                maintenance_in: 0.0,
                property_or_lodger: 0.0,
                pension: 0.0,
              },
            },
          },
        },
        disposable_income: {
          monthly_equivalents: {
            all_sources: {
              child_care: 0.0,
              rent_or_mortgage: 50.0,
              maintenance_out: 0.0,
              legal_aid: 0.0,
            },
            bank_transactions: {
              child_care: 0.0,
              rent_or_mortgage: 50.0,
              maintenance_out: 0.0,
              legal_aid: 0.0,
            },
            cash_transactions: {
              child_care: 0.0,
              rent_or_mortgage: 0.0,
              maintenance_out: 0.0,
              legal_aid: 0.0,
            },
          },
          childcare_allowance: 0.0,
          deductions: {
            dependants_allowance: 1457.45,
            disregarded_state_benefits: 0.0,
          },
        },
        capital: {
          capital_items: {
            liquid: [
              { description: "Bank acct 1", value: 0.0 },
              { description: "Bank acct 2", value: 0.0 },
              { description: "Bank acct 3", value: 0.0 }
            ],
            non_liquid: [],
            vehicles: [
              {
                value: 9000.0,
                loan_amount_outstanding: 0.0,
                date_of_purchase: "2018-05-20",
                in_regular_use: false,
                included_in_assessment: true,
                assessed_value: 9000.0,
              }
            ],
            properties: {
              main_home: {
                value: 500_000.0,
                outstanding_mortgage: 150_000.0,
                percentage_owned: 50.0,
                main_home: true,
                shared_with_housing_assoc: false,
                transaction_allowance: 15_000.0,
                allowable_outstanding_mortgage: 100_000.0,
                net_value: 385_000.0,
                net_equity: 192_500.0,
                main_home_equity_disregard: 100_000.0,
                assessed_equity: 92_500.0,
              },
              additional_properties: [],
            },
          },
        },
        remarks: {
          state_benefit_payment: {
            amount_variation: client_ids,
            unknown_frequency: client_ids,
          },
        },
      },
    }
  end
end
