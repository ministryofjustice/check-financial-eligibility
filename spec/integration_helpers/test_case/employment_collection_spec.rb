require "rails_helper"
require Rails.root.join("lib/integration_helpers/test_case/employment_collection.rb")

module TestCase
  RSpec.describe EmploymentCollection do
    let(:dec) { Date.new(2021, 12, 20) }
    let(:nov) { Date.new(2021, 11, 30) }
    let(:oct) { Date.new(2021, 10, 30) }
    let(:early_dec) { Date.new(2021, 12, 7) }
    let(:mid_dec) { Date.new(2021, 12, 15) }

    subject(:payload) { described_class.new(rows).payload }

    context "well formed spreadsheet" do
      context "single job" do
        let(:rows) { single_job_rows }

        it "returns expected payload" do
          expect(payload).to eq expected_single_job_payload
        end
      end

      context "multiple jobs" do
        let(:rows) { multi_job_rows }

        it "returns expected payload" do
          expect(payload).to eq expected_multi_job_payload
        end
      end
    end

    context "malformed_spreadsheet" do
      context "no job name specified on first row" do
        let(:rows) { missing_job_name_rows }

        it "raises" do
          expect { payload }.to raise_error RuntimeError, "No job name specified in column B for employment data"
        end
      end

      context "unknown key in column C of spreadsheet" do
        let(:rows) { unknown_key_rows }

        it "raises" do
          expect { payload }.to raise_error RuntimeError, "Unexpected key 'XXX-YYY-ZZZ' in column C of employment data"
        end
      end
    end

    def single_job_rows
      [
        ["employment_income", "Job 1:id1", "date", dec, "date as xx/xx/xx"],
        ["", "", "client_id", "id3"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["", "", "date", nov, "date as xx/xx/xx"],
        ["", "", "client_id", "id4"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["", "", "date", oct, "date as xx/xx/xx"],
        ["", "", "client_id", "id7"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["some other section"],
      ]
    end

    def multi_job_rows
      [
        ["employment_income", "Job 1:id1", "date", dec, "date as xx/xx/xx"],
        ["", "", "client_id", "id4"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["", "", "date", nov, "date as xx/xx/xx"],
        ["", "", "client_id", "id5"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["", "", "date", oct, "date as xx/xx/xx"],
        ["", "", "client_id", "id6"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["", "Job 2:id2", "date", early_dec, "date as xx/xx/xx"],
        ["", "", "client_id", "id6"],
        ["", "", "gross pay", 350.20],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -98, 44, "Enter as negative value unless refund"],
        ["", "", "national insurance", 0, "enter as negative figure for NIC deduction, positive for refund"],
        ["", "", "date", mid_dec, "date as xx/xx/xx"],
        ["", "", "client_id", "id7"],
        ["", "", "gross pay", 390],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -45.87, "Enter as negative value unless refund"],
        ["", "", "national insurance", 0, "enter as negative figure for NIC deduction, positive for refund"],
        ["some other section"],
      ]
    end

    def missing_job_name_rows
      [
        ["employment_income", "", "date", dec, "date as xx/xx/xx"],
        ["", "", "gross pay", 2550.33],
        ["", "", "benefits in kind", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["some other section"],
      ]
    end

    def unknown_key_rows
      [
        ["employment_income", "Job 1:id4", "date", dec, "date as xx/xx/xx"],
        ["", "", "client_id", "id9"],
        ["", "", "gross pay", 2550.33],
        ["", "", "XXX-YYY-ZZZ", 0.0],
        ["", "", "tax", -745.31, "Enter as negative value unless refund"],
        ["", "", "national insurance", -144.06, "enter as negative figure for NIC deduction, positive for refund"],
        ["some other section"],
      ]
    end

    def expected_single_job_payload
      {
        employment_income: [
          {
            name: "Job 1",
            client_id: "id1",
            payments: [
              {
                client_id: "id3",
                date: "2021-12-20",
                gross: 2550.33,
                benefits_in_kind: 0.0,
                tax: -745.31,
                national_insurance: -144.06,
                net_employment_income: 1660.96,
              },
              {
                client_id: "id4",
                date: "2021-11-30",
                gross: 2550.33,
                benefits_in_kind: 0.0,
                tax: -745.31,
                national_insurance: -144.06,
                net_employment_income: 1660.96,
              },
              {
                client_id: "id7",
                date: "2021-10-30",
                gross: 2550.33,
                benefits_in_kind: 0.0,
                tax: -745.31,
                national_insurance: -144.06,
                net_employment_income: 1660.96,
              },
            ],
          },
        ],
      }
    end

    def expected_multi_job_payload
      {
        employment_income: [
          {
            name: "Job 1",
            client_id: "id1",
            payments: [
              {
                client_id: "id4",
                date: "2021-12-20",
                gross: 2550.33,
                benefits_in_kind: 0.0,
                tax: -745.31,
                national_insurance: -144.06,
                net_employment_income: 1660.96,
              },
              {
                client_id: "id5",
                date: "2021-11-30",
                gross: 2550.33,
                benefits_in_kind: 0.0,
                tax: -745.31,
                national_insurance: -144.06,
                net_employment_income: 1660.96,
              },
              {
                client_id: "id6",
                date: "2021-10-30",
                gross: 2550.33,
                benefits_in_kind: 0.0,
                tax: -745.31,
                national_insurance: -144.06,
                net_employment_income: 1660.96,
              },
            ],
          },
          {
            name: "Job 2",
            client_id: "id2",
            payments: [
              {
                client_id: "id6",
                date: "2021-12-07",
                gross: 350.2,
                benefits_in_kind: 0.0,
                tax: -98,
                national_insurance: 0,
                net_employment_income: 252.2,
              },
              {
                client_id: "id7",
                date: "2021-12-15",
                gross: 390,
                benefits_in_kind: 0.0,
                tax: -45.87,
                national_insurance: 0,
                net_employment_income: 344.13,
              },
            ],
          },
        ],
      }
    end
  end
end
