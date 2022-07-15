require "rails_helper"

RSpec.describe "Full V5 passported spec " do
  let(:client_id) { "uuid or any unique string" }

  before do
    Dibber::Seeder.new(StateBenefitType,
                       "data/state_benefit_types.yml",
                       name_method: :label,
                       overwrite: true).build

    ENV["VERBOSE"] = "false"
    create :bank_holiday
    mock_lfa_responses
  end

  it "returns the expected payload with remarks" do
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
          "receives_qualifying_benefit" => true } }.to_json
  end

  def capitals_params
    { "bank_accounts" =>
        [{ "description" => "Money not in a bank account", "value" => "245.0" }] }.to_json
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
