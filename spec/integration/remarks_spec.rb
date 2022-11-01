require "rails_helper"

RSpec.describe "contribution_required Full Assessment with remarks" do
  let(:client_id) { "uuid or any unique string" }

  before do
    Dibber::Seeder.new(StateBenefitType,
                       "data/state_benefit_types.yml",
                       name_method: :label,
                       overwrite: true).build

    ENV["VERBOSE"] = "false"
    create :bank_holiday
  end

  it "returns the expected payload with all remarks" do
    mock_lfa_responses

    assessment_id = post_assessment
    post_applicant(assessment_id)
    post_proceeding_types(assessment_id)
    post_capitals(assessment_id)
    post_other_incomes(assessment_id)
    post_outgoings(assessment_id)
    post_state_benefits(assessment_id)
    post_explicit_remarks(assessment_id)

    get assessment_path(assessment_id), headers: v5_headers
    output_response(:get, :assessment)
    expect(deep_orderless_match(parsed_response[:assessment][:remarks], expected_remarks)).to be true
  end

  def deep_orderless_match(actual, expected)
    expect(actual.keys).to match_array(expected.keys)
    expect_matching_array(actual, expected, :state_benefit_payment, :amount_variation)
    expect_matching_array(actual, expected, :state_benefit_payment, :unknown_frequency)
    expect_matching_array(actual, expected, :other_income_payment, :amount_variation)
    expect_matching_array(actual, expected, :other_income_payment, :unknown_frequency)
    expect_matching_array(actual, expected, :outgoings_housing_cost, :amount_variation)
    expect_matching_array(actual, expected, :outgoings_maintenance, :unknown_frequency)
    expect(actual[:policy_disregards]).to match_array(expected[:policy_disregards])
  end

  def expect_matching_array(actual, expected, key1, key2)
    expect(actual[key1][key2]).to match_array(expected[key1][key2])
  end

  def post_assessment
    post assessments_path, params: assessment_params, headers: v5_headers
    output_response(:post, :assessment)
    parsed_response[:assessment_id]
  end

  def post_applicant(assessment_id)
    post assessment_applicant_path(assessment_id), params: applicant_params, headers: v5_headers
    output_response(:post, :applicant)
  end

  def post_proceeding_types(assessment_id)
    post assessment_proceeding_types_path(assessment_id), params: proceeding_types_params, headers: v5_headers
    output_response(:post, :applicant)
  end

  def post_capitals(assessment_id)
    post assessment_capitals_path(assessment_id), params: capitals_params, headers: v5_headers
    output_response(:post, :capitals)
  end

  def post_other_incomes(assessment_id)
    post assessment_other_incomes_path(assessment_id), params: other_income_params, headers: v5_headers
    output_response(:post, :other_incomes)
  end

  def post_outgoings(assessment_id)
    post assessment_outgoings_path(assessment_id), params: outgoings_params, headers: v5_headers
    output_response(:post, :outgoings)
  end

  def post_state_benefits(assessment_id)
    post assessment_state_benefits_path(assessment_id), params: state_benefit_params, headers: v5_headers
    output_response(:post, :state_benefits)
  end

  def post_explicit_remarks(assessment_id)
    post assessment_explicit_remarks_path(assessment_id), params: explicit_remarks_params, headers: v5_headers
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

  def v5_headers
    { "CONTENT_TYPE" => "application/json", "Accept" => "application/json;version=5" }
  end

  def assessment_params
    {
      client_reference_id: "psr-123",
      submission_date: "2019-06-06",
    }.to_json
  end

  def applicant_params
    {
      applicant: {
        date_of_birth: 20.years.ago.to_date,
        has_partner_opponent: false,
        involvement_type: "applicant",
        receives_qualifying_benefit: true,
      },
    }.to_json
  end

  def proceeding_types_params
    {
      proceeding_types: [
        {
          ccms_code: "DA005",
          client_involvement_type: "A",
        },
      ],
    }.to_json
  end

  def capitals_params
    {
      bank_accounts: [
        {
          description: "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}",
          value: Faker::Number.decimal(r_digits: 2),
        },
        {
          description: "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}",
          value: Faker::Number.decimal(r_digits: 2),
        },
      ],
      non_liquid_capital: [
        {
          description: "Ming vase",
          value: Faker::Number.decimal(r_digits: 2),
        },
        {
          description: "Aramco shares",
          value: Faker::Number.decimal(r_digits: 2),
        },
      ],
    }.to_json
  end

  def other_income_params
    {
      other_incomes: [
        {
          source: "maintenance_in", # varying amounts
          payments: [
            {
              date: "2019-11-01",
              amount: 1046.44,
              client_id: "OISL-001",
            },
            {
              date: "2019-10-01",
              amount: 1034.33,
              client_id: "OISL-002",
            },
            {
              date: "2019-09-01",
              amount: 1033.44,
              client_id: "OISL-003",
            },
          ],
        },
        {
          source: "friends_or_family", # varying amounts and unknown frequency
          payments: [
            {
              date: "2019-11-01",
              amount: 250.00,
              client_id: client_id,
            },
            {
              date: "2019-10-24",
              amount: 266.02,
              client_id: client_id,
            },
            {
              date: "2019-09-06",
              amount: 250.00,
              client_id: client_id,
            },
          ],
        },
      ],
    }.to_json
  end

  def outgoings_params
    {
      outgoings: [
        {
          name: "child_care", # no remarks
          payments: [
            {
              payment_date: "2019-11-01",
              amount: 256.00,
              client_id: client_id,
            },
            {
              payment_date: "2019-10-01",
              amount: 256.00,
              client_id: client_id,
            },
            {
              payment_date: "2019-09-01",
              amount: 256.00,
              client_id: client_id,
            },
          ],
        },
        {
          name: "maintenance_out",
          payments: [
            {
              payment_date: "2019-11-03",
              amount: 202.45,
              client_id: client_id,
            },
            {
              payment_date: "2019-11-01",
              amount: 202.45,
              client_id: client_id,
            },
            {
              payment_date: "2019-09-12",
              amount: 202.45,
              client_id: client_id,
            },
          ],
        },
        {
          name: "rent_or_mortgage", # varying amount
          payments: [
            {
              payment_date: "2019-11-03",
              amount: 1203.45,
              housing_cost_type: "mortgage",
              client_id: client_id,
            },
            {
              payment_date: "2019-10-03",
              amount: 1203.45,
              housing_cost_type: "mortgage",
              client_id: client_id,
            },
            {
              payment_date: "2019-09-03",
              amount: 1203.65,
              housing_cost_type: "mortgage",
              client_id: client_id,
            },
          ],
        },
      ],
    }.to_json
  end

  def state_benefit_params
    {
      state_benefits: [
        {
          name: "Child Benefit", # varying amounts, varying dates
          payments: [
            {
              date: "2019-11-01",
              amount: 1046.44,
              client_id: "CHB001",
            },
            {
              date: "2019-10-15",
              amount: 1034.33,
              client_id: "CHB002",
            },
            {
              date: "2019-09-04",
              amount: 1033.44,
              client_id: "CHB003",
            },
          ],
        },
        {
          name: "Carer's Allowance", # no Issues
          payments: [
            {
              date: "2019-11-01",
              amount: 250.00,
              client_id: client_id,
            },
            {
              date: "2019-10-01",
              amount: 250.00,
              client_id: client_id,
            },
            {
              date: "2019-09-01",
              amount: 250.00,
              client_id: client_id,
            },
          ],
        },
      ],
    }.to_json
  end

  def explicit_remarks_params
    {
      explicit_remarks: [
        {
          category: "policy_disregards",
          details: [
            "Grenfell tower fund",
            "Some other fund",
          ],
        },
      ],
    }.to_json
  end

  def expected_remarks
    {
      state_benefit_payment: {
        amount_variation: %w[CHB001 CHB002 CHB003],
        unknown_frequency: %w[CHB001 CHB002 CHB003],
      },
      other_income_payment: {
        amount_variation: [
          "OISL-001",
          "OISL-002",
          "OISL-003",
          client_id,
          client_id,
          client_id,
        ],
        unknown_frequency: [
          client_id,
          client_id,
          client_id,
        ],
      },
      outgoings_housing_cost: {
        amount_variation: [
          client_id,
          client_id,
          client_id,
        ],
      },
      outgoings_maintenance: {
        unknown_frequency: [
          client_id,
          client_id,
          client_id,
        ],
      },
      policy_disregards: [
        "Grenfell tower fund",
        "Some other fund",
      ],
    }
  end
end
