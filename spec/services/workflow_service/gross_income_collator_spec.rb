require 'rails_helper'

module WorkflowService
  RSpec.describe GrossIncomeCollator do
    let(:assessment) { create :assessment, :with_applicant }

    describe '.call' do
      subject { described_class.call assessment }

      it 'always returns a hash' do
        expect(subject).to be_a Hash
      end

      context 'upper income threshold' do
        before { subject }

        context 'threshold does not apply' do
          it 'calculates the threshold correctly when there are no dependants' do
            expect(subject[:upper_threshold]).to eq 999_999_999_999
          end

          context 'with child dependants' do
            let(:assessment) { create :assessment, :with_applicant, with_child_dependants: 5 }
            it 'calculates the threshold correctly when there are dependants' do
              expect(subject[:upper_threshold]).to eq 999_999_999_999
            end
          end
        end
      end

      context 'threshold applies' do
        before { allow(assessment).to receive(:matter_proceeding_type).and_return 'not_domestic_abuse' }
        context 'threshold applies, no child dependants' do
          it 'calculates the threshold correctly' do
            expect(subject[:upper_threshold]).to eq 2_657
          end
        end

        context 'threshold applies, 2 child dependants' do
          let(:assessment) { create :assessment, :with_applicant, with_child_dependants: 2 }
          it 'calculates the threshold correctly' do
            expect(subject[:upper_threshold]).to eq 2_657
          end
        end

        context 'threshold applies, 5 child dependants' do
          let(:assessment) { create :assessment, :with_applicant, with_child_dependants: 5 }
          it 'calculates the threshold correctly' do
            expect(subject[:upper_threshold]).to eq 2_879
          end
        end

        context 'threshold applies, 8 child dependants' do
          let(:assessment) { create :assessment, :with_applicant, with_child_dependants: 8 }
          it 'calculates the threshold correctly' do
            expect(subject[:upper_threshold]).to eq 3_545
          end
        end

        context 'threshold applies, 10 child dependants' do
          let(:assessment) { create :assessment, :with_applicant, with_child_dependants: 10 }
          it 'calculates the threshold correctly' do
            expect(subject[:upper_threshold]).to eq 3_989
          end
        end
      end
    end
  end
end
