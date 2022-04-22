require "rails_helper"

module Calculators
  RSpec.describe DependantAllowanceCalculator do
    describe "#call" do
      subject(:calculator) { described_class.new(dependant).call }

      before do
        allow_any_instance_of(described_class).to receive(:child_under_15_allowance).and_return 111.11
        allow_any_instance_of(described_class).to receive(:child_aged_15_allowance).and_return 222.22
        allow_any_instance_of(described_class).to receive(:child_16_and_over_allowance).and_return 333.33
        allow_any_instance_of(described_class).to receive(:adult_allowance).and_return 444.44
      end

      context "under 15" do
        context "with income" do
          let(:dependant) { create :dependant, :under15, monthly_income: 25.00 }

          it "returns the child under 15 allowance and does not subtract the income" do
            expect(calculator).to eq 111.11
          end
        end

        context "without income" do
          let(:dependant) { create :dependant, :under15, monthly_income: 0.0 }

          it "returns the child under 15 allowance" do
            expect(calculator).to eq 111.11
          end
        end
      end

      context "15 years old" do
        context "with income" do
          let(:dependant) { create :dependant, :aged15, monthly_income: 25.50 }

          it "returns the aged 15 allowance less the monthly income" do
            expect(calculator).to eq(222.22 - 25.50)
          end
        end

        context "with income greater than the allowance" do
          let(:dependant) { create :dependant, :aged15, monthly_income: 250.00 }

          it "returns zero" do
            expect(calculator).to be_zero
          end
        end

        context "without income" do
          let(:dependant) { create :dependant, :aged15, monthly_income: 30.55 }

          it "returns the aged 15 allowance less the monthly income" do
            expect(calculator).to eq(222.22 - 30.55)
          end
        end
      end

      context "16 or 17 years old" do
        context "in full time education" do
          context "with  no income" do
            let(:dependant) { create :dependant, :aged16or17, monthly_income: 0.0, in_full_time_education: true }

            it "returns the child 16 or over allowance with no income deduction" do
              expect(calculator).to eq 333.33
            end
          end

          context "with income" do
            let(:dependant) { create :dependant, :aged16or17, monthly_income: 100.01, in_full_time_education: true }

            it "returns the child 16 or over with no income deduction" do
              expect(calculator).to eq(333.33 - 100.01)
            end
          end

          context "with income greater than the allowance" do
            let(:dependant) { create :dependant, :aged16or17, monthly_income: 350.00, in_full_time_education: true }

            it "returns zero" do
              expect(calculator).to be_zero
            end
          end
        end

        context "not in full time education" do
          context "with  no income" do
            let(:dependant) { create :dependant, :aged16or17, monthly_income: 0.0, in_full_time_education: false }

            it "returns the adult allowance with no income deduction" do
              expect(calculator).to eq 444.44
            end
          end

          context "with income" do
            let(:dependant) { create :dependant, :aged16or17, monthly_income: 100.22, in_full_time_education: false }

            it "returns the adult allowance with no income deduction" do
              expect(calculator).to eq(444.44 - 100.22)
            end
          end
        end
      end

      context "over 18 years old" do
        context "with no income" do
          context "with capital assets < 8000" do
            let(:dependant) { create :dependant, :over18, monthly_income: 0.0, assets_value: 4_470 }

            it "returns the adult allowance with no deduction" do
              expect(calculator).to eq 444.44
            end
          end

          context "with capital assets > 8000" do
            let(:dependant) { create :dependant, :over18, monthly_income: 0.0, assets_value: 8_100 }

            it "returns the allowance of zero" do
              expect(calculator).to be_zero
            end
          end
        end

        context "with income" do
          context "with capital assets > 8000" do
            let(:dependant) { create :dependant, :over18, monthly_income: 0.0, assets_value: 8_100 }

            it "returns the allowance of zero" do
              expect(calculator).to eq 0.0
            end
          end
        end

        context "with capital assets < 8000" do
          let(:dependant) { create :dependant, :over18, monthly_income: 203.37, assets_value: 5_000 }

          it "returns the adult allowance with income deducted" do
            expect(calculator).to eq(444.44 - 203.37)
          end
        end
      end
    end

    # 2021 threshold date tests
    describe "retrieving threshold values for 2021" do
      let(:dependant) { create :dependant }

      subject(:calculator) { described_class.new(dependant) }

      context "before new allowances date" do
        before do
          dependant.assessment.submission_date = "Sun, 11 Apr 2021"
        end

        describe "child_under_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_under_15_allowance).to eq 296.65
          end
        end

        describe "child_aged_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_aged_15_allowance).to eq 296.65
          end
        end

        describe "child_16_and_over_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_16_and_over_allowance).to eq 296.65
          end
        end

        describe "adult_allowance" do
          it "returns the threshold value" do
            expect(calculator.adult_allowance).to eq 296.65
          end
        end
      end

      context "after new allowances date" do
        before do
          dependant.assessment.submission_date = "Mon, 12 Apr 2021"
        end

        describe "child_under_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_under_15_allowance).to eq 298.08
          end
        end

        describe "child_aged_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_aged_15_allowance).to eq 298.08
          end
        end

        describe "child_16_and_over_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_16_and_over_allowance).to eq 298.08
          end
        end

        describe "adult_allowance" do
          it "returns the threshold value" do
            expect(calculator.adult_allowance).to eq 298.08
          end
        end
      end
    end

    # 2022 threshold tests dates
    describe "retrieving threshold values for 2022" do
      let(:dependant) { create :dependant }

      subject(:calculator) { described_class.new(dependant) }

      context "before new allowances date" do
        before do
          dependant.assessment.submission_date = "Sun, 10 Apr 2022"
        end

        describe "child_under_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_under_15_allowance).to eq 298.08
          end
        end

        describe "child_aged_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_aged_15_allowance).to eq 298.08
          end
        end

        describe "child_16_and_over_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_16_and_over_allowance).to eq 298.08
          end
        end

        describe "adult_allowance" do
          it "returns the threshold value" do
            expect(calculator.adult_allowance).to eq 298.08
          end
        end
      end

      context "after new allowances date" do
        before do
          dependant.assessment.submission_date = "Mon, 11 Apr 2022"
        end

        describe "child_under_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_under_15_allowance).to eq 307.64
          end
        end

        describe "child_aged_15_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_aged_15_allowance).to eq 307.64
          end
        end

        describe "child_16_and_over_allowance" do
          it "returns the threshold value" do
            expect(calculator.child_16_and_over_allowance).to eq 307.64
          end
        end

        describe "adult_allowance" do
          it "returns the threshold value" do
            expect(calculator.adult_allowance).to eq 307.64
          end
        end
      end
    end
  end
end
