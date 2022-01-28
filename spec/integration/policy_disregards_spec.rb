require "rails_helper"

RSpec.describe "Eligible Full Assessment with policy disregard remarks" do
  let(:client_id) { "uuid or any unique string" }

  before do
    Dibber::Seeder.new(StateBenefitType,
                       "data/state_benefit_types.yml",
                       name_method: :label,
                       overwrite: true).build

    ENV["VERBOSE"] = "false"
    create :bank_holiday
  end

  before { mock_lfa_responses }

  it "returns the expected payload with no policy disregards remarks" do
    assessment_id = post_assessment
    post_applicant(assessment_id)
    post_capitals(assessment_id)
    post_dependants(assessment_id)
    post_outgoings(assessment_id)
    post_state_benefits(assessment_id)
    post_other_incomes(assessment_id)
    post_irregular_income(assessment_id)
    post_explicit_remarks(assessment_id)

    get assessment_path(assessment_id), headers: v3_headers
    output_response(:get, :assessment)

    expect(parsed_response[:assessment][:remarks]).to_not include(:policy_disregards)
  end

  def post_assessment
    post assessments_path, params: assessment_params, headers: headers
    output_response(:post, :assessment)
    parsed_response[:assessment_id]
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
    output_response(:post, :capitals)
  end

  def post_other_incomes(assessment_id)
    post assessment_other_incomes_path(assessment_id), params: other_income_params, headers: headers
    output_response(:post, :other_incomes)
  end

  def post_outgoings(assessment_id)
    post assessment_outgoings_path(assessment_id), params: outgoings_params, headers: headers
    output_response(:post, :outgoings)
  end

  def post_state_benefits(assessment_id)
    post assessment_state_benefits_path(assessment_id), params: state_benefit_params, headers: headers
    output_response(:post, :state_benefits)
  end

  def post_irregular_income(assessment_id)
    post assessment_irregular_incomes_path(assessment_id), params: student_loan_params, headers: headers
    output_response(:post, :irregular_income)
  end

  def post_explicit_remarks(assessment_id)
    post assessment_explicit_remarks_path(assessment_id), params: explicit_remarks_params, headers: headers
    output_response(:post, :explicit_remarks)
  end

  def output_response(method, object)
    puts ">>>>>>>>>>>> #{method.to_s.upcase} #{object} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n" if verbose?
    ap parsed_response if verbose?
    raise "Bad response: #{response.status}" unless response.status == 200
  end

  def verbose?
    ENV["VERBOSE"] == "true"
  end

  def headers
    { "CONTENT_TYPE" => "application/json" }
  end

  def v3_headers
    { "Accept" => "application/json;version=3" }
  end

  def assessment_params
    { "client_reference_id" => "L-YYV-4N6",
      "submission_date" => "2020-06-11",
      "matter_proceeding_type" => "domestic_abuse" }.to_json
  end

  def applicant_params
    { "applicant" =>
          { "date_of_birth" => "1981-04-11",
            "involvement_type" => "applicant",
            "has_partner_opponent" => false,
            "receives_qualifying_benefit" => false } }.to_json
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

  def explicit_remarks_params
    {
      explicit_remarks: [
        {
          category: "policy_disregards",
          details: [
            "Grenfell tower fund",
            "Some other fund"
          ],
        }
      ],
    }.to_json
  end
end
