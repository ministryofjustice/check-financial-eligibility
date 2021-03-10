require 'rails_helper'

module Collators
  RSpec.describe DisposableIncomeCollator do
    let(:assessment) { disposable_income_summary.assessment }
    let(:child_care_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:maintenance_out_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:gross_housing) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:legal_aid_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d }
    let(:housing_benefit) { Faker::Number.between(from: 1.25, to: gross_housing / 2).round(2) }
    let(:net_housing) { gross_housing - housing_benefit }
    let(:total_outgoings) { child_care_bank + maintenance_out_bank + net_housing + dependant_allowance + legal_aid_bank }

    let(:dependant_allowance) { 582.98 }

    let(:disposable_income_summary) do
      create :disposable_income_summary,
             child_care_bank: child_care_bank,
             maintenance_out_bank: maintenance_out_bank,
             gross_housing_costs: gross_housing,
             rent_or_mortgage_bank: gross_housing,
             legal_aid_bank: legal_aid_bank,
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

      context 'version 3' do
        let(:disposable_income_summary) do
          create :disposable_income_summary, :with_v3,
                 child_care_bank: child_care_bank,
                 maintenance_out_bank: maintenance_out_bank,
                 gross_housing_costs: gross_housing,
                 rent_or_mortgage_bank: gross_housing,
                 legal_aid_bank: legal_aid_bank,
                 housing_benefit: housing_benefit,
                 net_housing_costs: net_housing,
                 total_outgoings_and_allowances: 0.0,
                 dependant_allowance: dependant_allowance,
                 total_disposable_income: 0.0,
                 lower_threshold: 0.0,
                 upper_threshold: 0.0
        end

        let(:total_outgoings) do
          disposable_income_summary.child_care_cash +
            disposable_income_summary.maintenance_out_cash +
            disposable_income_summary.rent_or_mortgage_cash +
            disposable_income_summary.legal_aid_cash +
            child_care_bank +
            maintenance_out_bank +
            legal_aid_bank +
            net_housing +
            dependant_allowance
        end

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
            result = assessment.gross_income_summary.total_gross_income - disposable_income_summary.reload.total_outgoings_and_allowances
            expect(disposable_income_summary.total_disposable_income).to eq result
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

        context 'all transactions' do
          it 'updates with totals for all categories based on bank and cash transactions' do
            subject
            disposable_income_summary.reload
            child_care_total = disposable_income_summary.child_care_bank + disposable_income_summary.child_care_cash
            maintenance_out_total = disposable_income_summary.maintenance_out_bank + disposable_income_summary.maintenance_out_cash
            rent_or_mortgage_total = disposable_income_summary.rent_or_mortgage_bank + disposable_income_summary.rent_or_mortgage_cash
            legal_aid_total = disposable_income_summary.legal_aid_bank + disposable_income_summary.legal_aid_cash

            expect(disposable_income_summary.child_care_all_sources).to eq child_care_total
            expect(disposable_income_summary.maintenance_out_all_sources).to eq maintenance_out_total
            expect(disposable_income_summary.rent_or_mortgage_all_sources).to eq rent_or_mortgage_total
            expect(disposable_income_summary.legal_aid_all_sources).to eq legal_aid_total
          end
        end
      end
    end
  end
end
