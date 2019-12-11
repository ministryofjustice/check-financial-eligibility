require 'rails_helper'

RSpec.describe GrossIncomeSummary do
  let(:assessment) { create :assessment }
  let(:gross_income_summary) do
    create :gross_income_summary, assessment: assessment
  end

  describe '#summarise!' do
    let(:data) do
      {
        upper_threshold: Faker::Number.decimal
      }
    end

    subject { gross_income_summary.summarise! }

    before do
      allow(Collators::GrossIncomeCollator).to receive(:call).with(assessment).and_return(data)
      subject
      gross_income_summary.reload
    end

    it 'persists the data' do
      data.each do |method, value|
        expect(gross_income_summary.__send__(method).to_d).to eq(value.to_d)
      end
    end
  end
end
