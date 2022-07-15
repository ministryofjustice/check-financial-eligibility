require "rails_helper"

RSpec.describe "Full V5 passported spec " do
  let(:client_id) { "uuid or any unique string" }

  before do
    Dibber::Seeder.new(StateBenefitType,
                       "data/state_benefit_types.yml",
                       name_method: :label,
                       overwrite: true).build

    ENV["VERBOSE"] = "true"
    create :bank_holiday
    mock_lfa_responses
  end

  context "when applicant is passported" do
    let(:qualifying_benefit) { true }

    it "returns the expected payload without remarks" do
      VCR.use_cassette "v5_passported_full_assessment" do
        assessment_id = post_assessment
        post_proceeding_types(assessment_id)
        post_applicant(assessment_id)

        post_capitals(assessment_id)

        get assessment_path(assessment_id), headers: v5_headers
        output_response(:get, :assessment)

        remarks = parsed_response[:assessment][:remarks]
        expect(remarks).to eq({})
      end
    end
  end

  context "when applicant is not passported" do
    let(:qualifying_benefit) { false }

    it "returns the expected payload with remarks" do
      VCR.use_cassette "v5_non_passported_full_assessment" do
        assessment_id = post_assessment
        post_proceeding_types(assessment_id)
        post_applicant(assessment_id)
        post_capitals(assessment_id)
        post_dependants(assessment_id)
        post_outgoings(assessment_id)
        post_state_benefits(assessment_id)
        post_other_incomes(assessment_id)
        post_irregular_income(assessment_id)

        get assessment_path(assessment_id), headers: v5_headers
        output_response(:get, :assessment)

        remarks = parsed_response[:assessment][:remarks]

        deep_match(remarks[:state_benefit_payment], expected_remarks[:state_benefit_payment])
        expect(remarks[:other_income_payment][:amount_variation]).to match_array expected_remarks[:other_income_payment][:amount_variation]
        expect(remarks[:other_income_payment][:unknown_frequency]).to match_array expected_remarks[:other_income_payment][:unknown_frequency]
        expect(remarks[:outgoings_maintenance]).to match_array expected_remarks[:outgoings_maintenance]
        expect(remarks[:outgoings_housing_cost]).to match_array expected_remarks[:outgoings_housing_cost]
        expect(remarks[:outgoings_childcare]).to match_array expected_remarks[:outgoings_childcare]
        expect(remarks[:outgoings_legal_aid]).to match_array expected_remarks[:outgoings_legal_aid]
        expect(remarks[:other_income_payment][:amount_variation]).to match_array(expected_remarks[:other_income_payment][:amount_variation])
        expect(remarks[:other_income_payment][:unknown_frequency]).to match_array(expected_remarks[:other_income_payment][:unknown_frequency])
      end
    end
  end

  context 'when debugging ' do
    it 'does not return error' do
      VCR.use_cassette "debugging" do
        rq = "{\"client_reference_id\":\"L-KUT-FW2\",\"submission_date\":\"2022-07-15\"}"
        post assessments_path, params: rq, headers: v5_headers
        output_response(:post, :assessment)
        assessment_id = parsed_response[:assessment_id]

        rq = "{\"proceeding_types\":[{\"ccms_code\":\"DA002\",\"client_involvement_type\":\"A\"},{\"ccms_code\":\"SE013\",\"client_involvement_type\":\"A\"}]}"
        post assessment_proceeding_types_path(assessment_id), params: rq, headers: headers
        output_response(:post, :proceeding_types)

        rq = "{\"applicant\":{\"date_of_birth\":\"1980-01-10\",\"involvement_type\":\"applicant\",\"has_partner_opponent\":false,\"receives_qualifying_benefit\":true}}"
        post assessment_applicant_path(assessment_id), params: rq, headers: headers
        output_response(:post, :applicant)

        rq = "{\"bank_accounts\":[{\"description\":\"Current accounts\",\"value\":\"788.0\"}],\"non_liquid_capital\":[]}"
        post assessment_capitals_path(assessment_id), params: rq, headers: headers
        output_response(:post, :capitals)


        rq =  "{\"vehicles\":[{\"value\":\"3000.0\",\"loan_amount_outstanding\":\"0.0\",\"date_of_purchase\":\"2018-07-15\",\"in_regular_use\":true}]}"
        post assessment_vehicles_path(assessment_id), params: rq, headers: headers
        output_response(:post, :vehicles)

        rq = "{\"properties\":{\"main_home\":{\"value\":0.0,\"outstanding_mortgage\":0.0,\"percentage_owned\":0.0,\"shared_with_housing_assoc\":false},\"additional_properties\":[{\"value\":0,\"outstanding_mortgage\":0,\"percentage_owned\":0,\"shared_with_housing_assoc\":false}]}}"
        post assessment_properties_path(assessment_id), params: rq, headers: headers
        output_response(:post, :vehicles)

        rq = "{\"explicit_remarks\":[{\"category\":\"policy_disregards\",\"details\":[]}]}"
        post assessment_explicit_remarks_path(assessment_id), params: rq, headers: headers
        output_response(:post, :vehicles)


        get assessment_path(assessment_id), headers: v5_headers
        output_response(:get, :assessment)
      end

      #
      # >>>>>>>>>>>> /assessments /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #   "{\"client_reference_id\":\"L-KUT-FW2\",\"submission_date\":\"2022-07-15\"}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<
      #   CFE Submission :: call to CFE::CreateAssessmentService for 356088b6-513e-44b9-a7de-f8cc7f911f5e took 2.292592 seconds
      # >>>>>>>>>>>> /assessments/6c2a501e-ae25-4360-a2a5-c12050d779f7/proceeding_types /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #     "{\"proceeding_types\":[{\"ccms_code\":\"DA002\",\"client_involvement_type\":\"A\"},{\"ccms_code\":\"SE013\",\"client_involvement_type\":\"A\"}]}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<
      #     CFE Submission :: call to CFE::CreateProceedingTypesService for 356088b6-513e-44b9-a7de-f8cc7f911f5e took 0.62701 seconds
      # >>>>>>>>>>>> /assessments/6c2a501e-ae25-4360-a2a5-c12050d779f7/applicant /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #     "{\"applicant\":{\"date_of_birth\":\"1980-01-10\",\"involvement_type\":\"applicant\",\"has_partner_opponent\":false,\"receives_qualifying_benefit\":true}}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<
      #     CFE Submission :: call to CFE::CreateApplicantService for 356088b6-513e-44b9-a7de-f8cc7f911f5e took 0.127026 seconds
      # >>>>>>>>>>>> /assessments/6c2a501e-ae25-4360-a2a5-c12050d779f7/capitals /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #     "{\"bank_accounts\":[{\"description\":\"Current accounts\",\"value\":\"788.0\"}],\"non_liquid_capital\":[]}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<
      #     CFE Submission :: call to CFE::CreateCapitalsService for 356088b6-513e-44b9-a7de-f8cc7f911f5e took 0.17218 seconds
      # >>>>>>>>>>>> /assessments/6c2a501e-ae25-4360-a2a5-c12050d779f7/vehicles /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #     "{\"vehicles\":[{\"value\":\"3000.0\",\"loan_amount_outstanding\":\"0.0\",\"date_of_purchase\":\"2018-07-15\",\"in_regular_use\":true}]}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<
      #     CFE Submission :: call to CFE::CreateVehiclesService for 356088b6-513e-44b9-a7de-f8cc7f911f5e took 0.128534 seconds
      # >>>>>>>>>>>> /assessments/6c2a501e-ae25-4360-a2a5-c12050d779f7/properties /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #     "{\"properties\":{\"main_home\":{\"value\":0.0,\"outstanding_mortgage\":0.0,\"percentage_owned\":0.0,\"shared_with_housing_assoc\":false},\"additional_properties\":[{\"value\":0,\"outstanding_mortgage\":0,\"percentage_owned\":0,\"shared_with_housing_assoc\":false}]}}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<
      #     CFE Submission :: call to CFE::CreatePropertiesService for 356088b6-513e-44b9-a7de-f8cc7f911f5e took 0.152368 seconds
      # >>>>>>>>>>>> /assessments/6c2a501e-ae25-4360-a2a5-c12050d779f7/explicit_remarks /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:73 <<<<<<<<<<<<
      #     "{\"explicit_remarks\":[{\"category\":\"policy_disregards\",\"details\":[]}]}"
      # >>>>>>>>>>>>  /Users/stephenrichards/moj/apply/app/services/cfe/base_service.rb:75 <<<<<<<<<<<<





    end
  end

  def post_assessment
    post assessments_path, params: assessment_params, headers: v5_headers
    output_response(:post, :assessment)
    parsed_response[:assessment_id]
  end

  def post_proceeding_types(assessment_id)
    post assessment_proceeding_types_path(assessment_id), params: proceeding_type_params, headers: headers
    output_response(:post, :proceeding_types)
  end

  def post_applicant(assessment_id)
    post assessment_applicant_path(assessment_id), params: applicant_params, headers: headers
    output_response(:post, :applicant)
  end

  def post_capitals(assessment_id)
    post assessment_capitals_path(assessment_id), params: capitals_params, headers: headers
    output_response(:post, :capitals)
  end

  def post_dependants(assessment_id)
    post assessment_dependants_path(assessment_id), params: dependants_params, headers: headers
    output_response(:post, :dependants)
  end

  def post_outgoings(assessment_id)
    post assessment_outgoings_path(assessment_id), params: outgoings_params, headers: headers
    output_response(:post, :outgoings)
  end

  def post_state_benefits(assessment_id)
    post assessment_state_benefits_path(assessment_id), params: state_benefit_params, headers: headers
    output_response(:post, :state_benefits)
  end

  def post_other_incomes(assessment_id)
    post assessment_other_incomes_path(assessment_id), params: other_income_params, headers: headers
    output_response(:post, :other_incomes)
  end

  def post_irregular_income(assessment_id)
    post assessment_irregular_incomes_path(assessment_id), params: student_loan_params, headers: headers
    output_response(:post, :irregular_income)
  end

  def output_response(method, object)
    puts ">>>>>>>>>>>> #{method.to_s.upcase} #{object} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n" if verbose?
    ap parsed_response if verbose?

    raise "Bad response: #{response.status}" unless response.status == 200
  end

  def assessment_params
    {
      "client_reference_id" => "L-YYV-4N6",
      "submission_date" => "2020-06-11",
    }.to_json
  end

  def proceeding_type_params
    {
      "proceeding_types" => [
        { "ccms_code" => "DA004", "client_involvement_type" => "A" },
        { "ccms_code" => "DA020", "client_involvement_type" => "A" },
        { "ccms_code" => "SE004", "client_involvement_type" => "A" },
        { "ccms_code" => "SE013", "client_involvement_type" => "A" },
      ],
    }.to_json
  end

  def applicant_params
    { "applicant" =>
        { "date_of_birth" => "1981-04-11",
          "involvement_type" => "applicant",
          "has_partner_opponent" => false,
          "receives_qualifying_benefit" => qualifying_benefit } }.to_json
  end

  def capitals_params
    { "bank_accounts" =>
        [{ "description" => "Money not in a bank account", "value" => "50.0" }],
      "non_liquid_capital" =>
        [{ "description" => "Any valuable items worth more than £500",
           "value" => "700.0" }] }.to_json
  end

  def dependants_params
    { "dependants" =>
        [{ "date_of_birth" => "2010-03-05",
           "relationship" => "child_relative",
           "monthly_income" => 0.0,
           "in_full_time_education" => false,
           "assets_value" => 0.0 }] }.to_json
  end

  def other_income_params
    { "other_incomes" =>
        [{ "source" => "Friends or family",
           "payments" =>
             [{ "date" => "2020-04-11",
                "amount" => 22.42,
                "client_id" => "TX-other-income-friends-family-1" },
              { "date" => "2020-05-11",
                "amount" => 50.0,
                "client_id" => "TX-other-income-friends-family-2" },
              { "date" => "2020-06-09",
                "amount" => 70.0,
                "client_id" => "TX-other-income-friends-family-3" }] },
         { "source" => "Maintenance in",
           "payments" =>
             [{ "date" => "2020-04-04",
                "amount" => 25.0,
                "client_id" => "TX-other-income-maintenance-in-1" },
              { "date" => "2020-05-14",
                "amount" => 43.5,
                "client_id" => "TX-other-income-maintenance-in-2" },
              { "date" => "2020-06-10",
                "amount" => 50.36,
                "client_id" => "TX-other-income-maintenance-in-3" }] },
         { "source" => "Pension",
           "payments" =>
             [{ "date" => "2020-04-10",
                "amount" => 40.0,
                "client_id" => "TX-other-income-pension-1" },
              { "date" => "2020-05-06",
                "amount" => 137.6,
                "client_id" => "TX-other-income-pension-2" },
              { "date" => "2020-06-09",
                "amount" => 70.0,
                "client_id" => "TX-other-income-pension-3" }] },
         { "source" => "Property or lodger",
           "payments" =>
             [{ "date" => "2020-04-06",
                "amount" => 137.6,
                "client_id" => "TX-other-income-property-1" },
              { "date" => "2020-05-03",
                "amount" => 35.49,
                "client_id" => "TX-other-income-property-2" },
              { "date" => "2020-06-11",
                "amount" => 50.0,
                "client_id" => "TX-other-income-property-3" }] }] }
      .to_json
  end

  def outgoings_params
    { "outgoings" =>
        [{ "name" => "maintenance_out",
           "payments" =>
             [{ "payment_date" => "2020-04-22",
                "amount" => 0.01,
                "client_id" => "TX-outgoing-maintenance-1" },
              { "payment_date" => "2020-05-19",
                "amount" => 7.99,
                "client_id" => "TX-outgoing-maintenance-2" },
              { "payment_date" => "2020-06-10",
                "amount" => 5.0,
                "client_id" => "TX-outgoing-maintenance-3" }] },
         { "name" => "rent_or_mortgage",
           "payments" =>
             [{ "payment_date" => "2020-04-22",
                "amount" => 36.59,
                "client_id" => "TX-outgoing-rent-mortgage-1" },
              { "payment_date" => "2020-05-23",
                "amount" => 100.0,
                "client_id" => "TX-outgoing-rent-mortgage-2" },
              { "payment_date" => "2020-06-01",
                "amount" => 46.82,
                "client_id" => "TX-outgoing-rent-mortgage-3" }] },
         { "name" => "child_care",
           "payments" =>
             [{ "payment_date" => "2020-04-23",
                "amount" => 20.0,
                "client_id" => "TX-outgoing-rent-child_care-1" },
              { "payment_date" => "2020-05-25",
                "amount" => 10.5,
                "client_id" => "TX-outgoing-rent-child_care-2" },
              { "payment_date" => "2020-06-10",
                "amount" => 40.0,
                "client_id" => "TX-outgoing-rent-child_care-3" }] },
         { "name" => "legal_aid",
           "payments" =>
             [{ "payment_date" => "2020-04-25",
                "amount" => 24.5,
                "client_id" => "TX-outgoing-rent-legal-aid-1" },
              { "payment_date" => "2020-05-22",
                "amount" => 36.59,
                "client_id" => "TX-outgoing-rent-legal-aid-2" },
              { "payment_date" => "2020-06-09",
                "amount" => 20.56,
                "client_id" => "TX-outgoing-rent-legal-aid-3" }] }] }.to_json
  end

  def state_benefit_params
    { "state_benefits" =>
        [{ "name" => "Manually chosen",
           "payments" =>
             [{ "date" => "2020-04-10",
                "amount" => 50.36,
                "client_id" => "TX-state-benefits-1" },
              { "date" => "2020-05-28",
                "amount" => 40.0,
                "client_id" => "TX-state-benefits-2" },
              { "date" => "2020-06-06",
                "amount" => 22.42,
                "client_id" => "TX-state-benefits-3" }] }] }.to_json
  end

  def student_loan_params
    { "payments" =>
        [{ "income_type" => "student_loan",
           "frequency" => "annual",
           "amount" => 100.0 }] }.to_json
  end

  def expected_remarks
    { state_benefit_payment: { amount_variation: %w[TX-state-benefits-1 TX-state-benefits-2 TX-state-benefits-3],
                               unknown_frequency: %w[TX-state-benefits-1 TX-state-benefits-2 TX-state-benefits-3] },
      other_income_payment: { amount_variation: %w[TX-other-income-friends-family-1
                                                   TX-other-income-friends-family-2
                                                   TX-other-income-friends-family-3
                                                   TX-other-income-maintenance-in-1
                                                   TX-other-income-maintenance-in-2
                                                   TX-other-income-maintenance-in-3
                                                   TX-other-income-pension-1
                                                   TX-other-income-pension-2
                                                   TX-other-income-pension-3
                                                   TX-other-income-property-1
                                                   TX-other-income-property-2
                                                   TX-other-income-property-3],
                              unknown_frequency: %w[TX-other-income-friends-family-1
                                                    TX-other-income-friends-family-2
                                                    TX-other-income-friends-family-3
                                                    TX-other-income-maintenance-in-1
                                                    TX-other-income-maintenance-in-2
                                                    TX-other-income-maintenance-in-3
                                                    TX-other-income-pension-1
                                                    TX-other-income-pension-2
                                                    TX-other-income-pension-3
                                                    TX-other-income-property-1
                                                    TX-other-income-property-2
                                                    TX-other-income-property-3] },
      outgoings_maintenance: { amount_variation: %w[TX-outgoing-maintenance-1
                                                    TX-outgoing-maintenance-2
                                                    TX-outgoing-maintenance-3],
                               unknown_frequency: %w[TX-outgoing-maintenance-1
                                                     TX-outgoing-maintenance-2
                                                     TX-outgoing-maintenance-3] },
      outgoings_housing_cost: { amount_variation: %w[TX-outgoing-rent-mortgage-1
                                                     TX-outgoing-rent-mortgage-2
                                                     TX-outgoing-rent-mortgage-3],
                                unknown_frequency: %w[TX-outgoing-rent-mortgage-1
                                                      TX-outgoing-rent-mortgage-2
                                                      TX-outgoing-rent-mortgage-3] },
      outgoings_childcare: { amount_variation: %w[TX-outgoing-rent-child_care-1
                                                  TX-outgoing-rent-child_care-2
                                                  TX-outgoing-rent-child_care-3],
                             unknown_frequency: %w[TX-outgoing-rent-child_care-1
                                                   TX-outgoing-rent-child_care-2
                                                   TX-outgoing-rent-child_care-3] },
      outgoings_legal_aid: { amount_variation: %w[TX-outgoing-rent-legal-aid-1
                                                  TX-outgoing-rent-legal-aid-2
                                                  TX-outgoing-rent-legal-aid-3],
                             unknown_frequency: %w[TX-outgoing-rent-legal-aid-1
                                                   TX-outgoing-rent-legal-aid-2
                                                   TX-outgoing-rent-legal-aid-3] } }
  end

  def headers
    { "CONTENT_TYPE" => "application/json" }
  end

  def v5_headers
    { "CONTENT_TYPE" => "application/json", "Accept" => "application/json;version=5" }
  end

  def verbose?
    ENV["VERBOSE"] == "true"
  end
end
