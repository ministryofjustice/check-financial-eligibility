require 'rails_helper'

module Utilities
  RSpec.describe EmploymentIncomeVariationChecker do
    let(:employment) { create :employment }

    before do
      amounts.each do |amount|
        create :employment_payment, employment: employment, gross_income_monthly_equiv: amount
      end
    end

    subject(:service_call) { described_class.call(employment) }

    context 'no variance' do
      let(:amounts) { [ 2000.0, 2000.0, 2000.0, 2000.0] }
      it 'returns zero' do
        expect(service_call).to be_zero
      end
    end

    context 'variances' do
      let(:amounts) { [ 879.33, 899.22, 733.22, 801.0, 902.15] }
      it 'returns difference between highest and lowest' do
        expect(service_call).to eq 168.93
      end
    end
  end
end
