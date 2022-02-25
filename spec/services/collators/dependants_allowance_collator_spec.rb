require "rails_helper"

module Collators
  RSpec.describe DependantsAllowanceCollator do
    let(:assessment) { create :assessment, :with_disposable_income_summary }
    let(:disposable_income_summary) { assessment.disposable_income_summary }

    subject(:collator) { described_class.call(assessment) }

    describe ".call" do
      context "no dependants" do
        it "leaves the monthly dependants allowance as zero" do
          expect(assessment.dependants).to be_empty
          collator
          expect(disposable_income_summary.dependant_allowance).to eq 0.0
        end
      end

      context "with dependants" do
        let(:dependant1) { create :dependant, assessment: assessment }
        let(:dependant2) { create :dependant, assessment: assessment }

        it "updates the dependant records and writes the sum to the diposable income summary" do
          allow(Calculators::DependantAllowanceCalculator).to receive(:new)
            .with(dependant1)
            .and_return(instance_double(Calculators::DependantAllowanceCalculator, call: 123.45))
          allow(Calculators::DependantAllowanceCalculator).to receive(:new)
            .with(dependant2)
            .and_return(instance_double(Calculators::DependantAllowanceCalculator, call: 456.78))
          collator
          expect(dependant1.reload.dependant_allowance).to eq 123.45
          expect(dependant2.reload.dependant_allowance).to eq 456.78
          expect(disposable_income_summary.dependant_allowance).to eq(123.45 + 456.78)
        end
      end
    end
  end
end
