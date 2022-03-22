require "rails_helper"

RSpec.describe "Full Assessment with remarks" do
  let(:client_id) { "uuid or any unique string" }
  let(:assessment_id) { initialize_assessment }

  before do
    ENV["VERBOSE"] = "false"
    create :bank_holiday
    mock_lfa_responses
  end

  context "when there are two employments" do
    it "returns multiple employments remarks" do
      post_employments(assessment_id, multiple_employment_params.to_json)
      get assessment_path(assessment_id), headers: v4_headers
      output_response(:get, :assessment)
      expect(remarks.dig(:employment, :multiple_employments)).to match_array(%w[job-1-id job-2-id])
    end
  end

  context "amount variation" do
    context "when gross employment income amounts vary by more than £60" do
      it "returns multiple varying amounts remarks for gross employment income" do
        post_employments(assessment_id, varying_gross_income_amounts.to_json)
        get assessment_path(assessment_id), headers: v4_headers
        output_response(:get, :assessment)
        expect(remarks.dig(:employment_gross_income, :amount_variation)).to match_array(%w[Job-1-oct Job-1-nov Job-1-dec])
      end
    end

    context "when gross employment income amounts vary by less than £60" do
      it "does not return remarks about varying amounts" do
        post_employments(assessment_id, varying_small_gross_income_amounts.to_json)
        get assessment_path(assessment_id), headers: v4_headers
        output_response(:get, :assessment)
        expect(remarks.dig(:employment_gross_income, :amount_variation)).to be_nil
      end
    end

    context "when tax amount varies" do
      it "does not return remarks about varying amounts" do
        post_employments(assessment_id, varying_tax_amounts.to_json)
        get assessment_path(assessment_id), headers: v4_headers
        output_response(:get, :assessment)
        expect(remarks.dig(:employment_tax, :amount_variation)).to be_nil
      end
    end
  end

  context "when there are refunds" do
    context "tax refund" do
      it "adds a refund remark for the payments with the tax refund" do
        post_employments(assessment_id, refunds.to_json)
        get assessment_path(assessment_id), headers: v4_headers
        output_response(:get, :assessment)
        expect(remarks.dig(:employment_tax, :refunds)).to match_array(%w[Job-1-oct Job-1-dec])
      end
    end

    context "National Insurance refund" do
      it "adds a remark for the employment payment with an NI refund" do
        post_employments(assessment_id, refunds.to_json)
        get assessment_path(assessment_id), headers: v4_headers
        output_response(:get, :assessment)
        expect(remarks.dig(:employment_nic, :refunds)).to eq(["Job-1-dec"])
      end
    end
  end

  def multiple_employment_params
    {
      employment_income: [
        {
          name: "Job 1",
          client_id: "job-1-id",
          payments: [
            { client_id: "Job-1-nov", date: "2021-11-12", gross: 0.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-oct", date: "2021-10-12", gross: 0.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-dec", date: "2021-12-12", gross: 0.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
          ],
        },
        {
          name: "Job 2",
          client_id: "job-2-id",
          payments: [],
        },
      ],
    }
  end

  def varying_gross_income_amounts
    {
      employment_income: [
        {
          name: "Job 1",
          client_id: "job-1-id",
          payments: [
            { client_id: "Job-1-nov", date: "2021-11-12", gross: 1200.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-oct", date: "2021-10-12", gross: 1300.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-dec", date: "2021-12-12", gross: 730.2, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
          ],
        },
      ],
    }
  end

  def varying_small_gross_income_amounts
    {
      employment_income: [
        {
          name: "Job 1",
          client_id: "job-1-id",
          payments: [
            { client_id: "Job-1-nov", date: "2021-11-12", gross: 1200.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-oct", date: "2021-10-12", gross: 1259.0, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-dec", date: "2021-12-12", gross: 1255.2, benefits_in_kind: 0.0, tax: 128.0, national_insurance: 0.0, net_employment_income: 128.0 },
          ],
        },
      ],
    }
  end

  def varying_tax_amounts
    {
      employment_income: [
        {
          name: "Job 1",
          client_id: "job-1-id",
          payments: [
            { client_id: "Job-1-nov", date: "2021-11-12", gross: 1200.0, benefits_in_kind: 0.0, tax: -128.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-oct", date: "2021-10-12", gross: 1200.0, benefits_in_kind: 0.0, tax: -267.0, national_insurance: 0.0, net_employment_income: 128.0 },
            { client_id: "Job-1-dec", date: "2021-12-12", gross: 1200.0, benefits_in_kind: 0.0, tax: -1.0, national_insurance: 0.0, net_employment_income: 128.0 },
          ],
        },
      ],
    }
  end

  def refunds
    {
      employment_income: [
        {
          name: "Job 1",
          client_id: "job-1-id",
          payments: [
            { client_id: "Job-1-nov", date: "2021-11-12", gross: 1200.0, benefits_in_kind: 0.0, tax: -128.0, national_insurance: -33.44, net_employment_income: 128.0 },
            { client_id: "Job-1-oct", date: "2021-10-12", gross: 1200.0, benefits_in_kind: 0.0, tax: 257.8, national_insurance: -22.0, net_employment_income: 128.0 },
            { client_id: "Job-1-dec", date: "2021-12-12", gross: 1200.0, benefits_in_kind: 0.0, tax: 44.0, national_insurance: 10.0, net_employment_income: 128.0 },
          ],
        },
      ],
    }
  end

  def initialize_assessment
    id = post_assessment
    post_applicant(id)
    id
  end

  def remarks
    parsed_response[:assessment][:remarks]
  end

  def post_assessment
    post assessments_path, params: assessment_params, headers: post_headers
    output_response(:post, :assessment)
    parsed_response[:assessment_id]
  end

  def post_applicant(assessment_id)
    post assessment_applicant_path(assessment_id), params: applicant_params, headers: post_headers
    output_response(:post, :applicant)
  end

  def post_employments(assessment_id, employment_params)
    post assessment_employments_path(assessment_id), params: employment_params, headers: post_headers
    output_response(:post, :employments)
  end

  def output_response(method, object)
    puts ">>>>>>>>>>>> #{method.to_s.upcase} #{object} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n" if verbose?
    ap parsed_response if verbose?
    raise "Bad response: #{response.status}" unless response.status == 200
  end

  def verbose?
    ENV["VERBOSE"] == "true"
  end

  def post_headers
    { "CONTENT_TYPE" => "application/json" }
  end

  def v4_headers
    { "Accept" => "application/json;version=4" }
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
end
