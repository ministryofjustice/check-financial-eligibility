require "rails_helper"

module Collators
  RSpec.describe CapitalCollator do
    let(:assessment) { create :assessment, :with_capital_summary, :with_applicant }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:submission_date) { assessment.submission_date }
    let(:capital_summary) { assessment.capital_summary }
    let(:today) { Date.new(2019, 4, 2) }

    describe ".call" do
      subject(:collator) { described_class.call assessment }

      it "always returns a hash" do
        expect(collator).to be_a Hash
      end

      context "liquid capital" do
        it "calls LiquidCapitalAssessment and updates capital summary with the result" do
          liquid_capital_service = instance_double Assessors::LiquidCapitalAssessor
          allow(Assessors::LiquidCapitalAssessor).to receive(:new).with(assessment).and_return(liquid_capital_service)
          allow(liquid_capital_service).to receive(:call).and_return(145.83)
          expect(collator[:total_liquid]).to eq 145.83
        end
      end

      context "property_assessment" do
        it "instantiates and calls the Property Assessment service" do
          property_service = instance_double Calculators::PropertyCalculator
          allow(Calculators::PropertyCalculator).to receive(:new).and_return(property_service)
          allow(property_service).to receive(:call).and_return(23_000.0)
          collator
          expect(collator[:total_property]).to eq 23_000.0
        end
      end

      context "vehicle assessment" do
        it "instantiates and calls the Vehicle Assesment service" do
          vehicle_service = instance_double Assessors::VehicleAssessor
          allow(Assessors::VehicleAssessor).to receive(:new).with(assessment).and_return(vehicle_service)
          allow(vehicle_service).to receive(:call).and_return(2_500.0)
          collator
          expect(collator[:total_vehicle]).to eq 2_500.0
        end
      end

      context "non_liquid_capital_assessment" do
        it "instantiates and calls NonLiquidCapitalAssessment" do
          nlcas = instance_double Assessors::NonLiquidCapitalAssessor
          allow(Assessors::NonLiquidCapitalAssessor).to receive(:new).with(assessment).and_return(nlcas)
          allow(nlcas).to receive(:call).and_return(500)
          collator
          expect(collator[:total_non_liquid]).to eq 500.0
        end
      end

      context "pensioner disregard" do
        it "instantiates and calls the PensionerCapitalDisregard service" do
          pcd = instance_double Calculators::PensionerCapitalDisregardCalculator
          allow(Calculators::PensionerCapitalDisregardCalculator).to receive(:new).with(assessment).and_return(pcd)
          allow(pcd).to receive(:value).and_return(100_000)
          collator
          expect(collator[:pensioner_capital_disregard]).to eq 100_000
        end
      end

      context "subject matter of dispute disregard" do
        it "instantiates and calls the SubjectMatterOfDisputeDiregardCalculator service" do
          smod = instance_double Calculators::SubjectMatterOfDisputeDisregardCalculator
          allow(Calculators::SubjectMatterOfDisputeDisregardCalculator).to receive(:new).with(assessment).and_return(smod)
          allow(smod).to receive(:value).and_return(50_000)
          collator
          expect(collator[:subject_matter_of_dispute_disregard]).to eq 50_000
        end
      end

      context "summarization of result_fields" do
        it "summarizes the results it gets from the subservices" do
          liquid_capital_service = instance_double Assessors::LiquidCapitalAssessor
          nlcas = instance_double Assessors::NonLiquidCapitalAssessor
          vehicle_service = instance_double Assessors::VehicleAssessor
          property_service = instance_double Calculators::PropertyCalculator
          pcd = instance_double Calculators::PensionerCapitalDisregardCalculator
          smod = instance_double Calculators::SubjectMatterOfDisputeDisregardCalculator

          allow(Assessors::LiquidCapitalAssessor).to receive(:new).with(assessment).and_return(liquid_capital_service)
          allow(Assessors::NonLiquidCapitalAssessor).to receive(:new).with(assessment).and_return(nlcas)
          allow(Assessors::VehicleAssessor).to receive(:new).with(assessment).and_return(vehicle_service)
          allow(Calculators::PropertyCalculator).to receive(:new).and_return(property_service)
          allow(Calculators::PensionerCapitalDisregardCalculator).to receive(:new).and_return(pcd)
          allow(Calculators::SubjectMatterOfDisputeDisregardCalculator).to receive(:new).with(assessment).and_return(smod)

          allow(liquid_capital_service).to receive(:call).and_return(145.83)
          allow(nlcas).to receive(:call).and_return(500)
          allow(vehicle_service).to receive(:call).and_return(2_500.0)
          allow(property_service).to receive(:call).and_return(23_000.0)
          allow(pcd).to receive(:value).and_return(100_000)
          allow(smod).to receive(:value).and_return(5_000)

          collator

          expect(collator[:total_liquid]).to eq 145.83
          expect(collator[:total_non_liquid]).to eq 500
          expect(collator[:total_vehicle]).to eq 2_500
          expect(collator[:total_property]).to eq 23_000
          expect(collator[:total_mortgage_allowance]).to eq 999_999_999_999
          expect(collator[:total_capital]).to eq 26_145.83
          expect(collator[:pensioner_capital_disregard]).to eq 100_000
          expect(collator[:subject_matter_of_dispute_disregard]).to eq 5_000
          expect(collator[:assessed_capital]).to eq(-78_854.17)
        end
      end
    end
  end
end
