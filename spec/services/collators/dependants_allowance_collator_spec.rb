require "rails_helper"

module Collators
  RSpec.describe DependantsAllowanceCollator do
    let(:assessment) { create :assessment, :with_disposable_income_summary }
    let(:disposable_income_summary) { assessment.disposable_income_summary }

    subject(:collator) do
      described_class.call(dependants: assessment.dependants,
                           submission_date: assessment.submission_date)
    end

    describe ".call" do
      context "no dependants" do
        it "leaves the monthly dependants allowance as zero" do
          expect(assessment.dependants).to be_empty
          expect(collator).to eq 0.0
        end
      end

      context "with dependants" do
        let(:dependant1) { create :dependant, assessment: }
        let(:dependant2) { create :dependant, assessment: }

        it "updates the dependant records and writes the sum to the diposable income summary" do
          allow(Calculators::DependantAllowanceCalculator).to receive(:new)
            .with(dependant1, assessment.submission_date)
            .and_return(instance_double(Calculators::DependantAllowanceCalculator, call: 123.45))
          allow(Calculators::DependantAllowanceCalculator).to receive(:new)
            .with(dependant2, assessment.submission_date)
            .and_return(instance_double(Calculators::DependantAllowanceCalculator, call: 456.78))

          expect(collator).to eq(123.45 + 456.78)
          expect(dependant1.reload.dependant_allowance).to eq 123.45
          expect(dependant2.reload.dependant_allowance).to eq 456.78
        end
      end
    end
  end
end
