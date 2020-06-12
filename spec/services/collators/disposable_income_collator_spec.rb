require 'rails_helper'

module Collators
  RSpec.describe DisposableIncomeCollator do
    let(:assessment)  { disposable_income_summary.assessment }
    let(:childcare) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:maintenance) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:gross_housing) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:legal_aid) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:housing_benefit) { Faker::Number.between(from: 1.25, to: gross_housing / 2).round(2) }
    let(:net_housing) { gross_housing - housing_benefit }
    let(:total_outgoings) { childcare + maintenance + net_housing + dependant_allowance + legal_aid }

    let(:dependant_allowance) { 582.98 }

    let(:disposable_income_summary) do
      create :disposable_income_summary,
             childcare: childcare,
             maintenance: maintenance,
             gross_housing_costs: gross_housing,
             legal_aid: legal_aid,
             housing_benefit: housing_benefit,
             net_housing_costs: net_housing,
             total_outgoings_and_allowances: 0.0,
             dependant_allowance: dependant_allowance,
             total_disposable_income: 0.0,
             lower_threshold: 0.0,
             upper_threshold: 0.0
    end

    let!(:gross_income_summary) { create :gross_income_summary, assessment: assessment }

    describe '.call' do
      subject { described_class.call(assessment) }

      context 'total_monthly_outgoings' do
        it 'sums childcare, legal_aid, maintenance and housing costs' do
          subject
          expect(disposable_income_summary.reload.total_outgoings_and_allowances).to eq total_outgoings
        end
      end

      context 'total disposable income' do
        before do
          assessment.gross_income_summary.update!(total_gross_income: total_outgoings + 1500.0)
        end
        it 'is populated with result of gross income minus total outgoings and allowances' do
          subject
          expect(disposable_income_summary.total_disposable_income).to eq 1500.0
        end
      end

      context 'lower threshold' do
        it 'populates the lower threshold' do
          subject
          expect(disposable_income_summary.lower_threshold).to eq 315.0
        end
      end

      context 'upper threshold' do
        context 'domestic abuse' do
          it 'populates it with infinity' do
            subject
            expect(disposable_income_summary.upper_threshold).to eq 999_999_999_999.0
          end
        end

        context 'non_domestic_abuse' do
          it 'populates it with the standard upper limit' do
            expect(assessment).to receive(:matter_proceeding_type).and_return('housing')
            subject
            expect(disposable_income_summary.upper_threshold).to eq 733.0
          end
        end
      end
    end
  end
end
