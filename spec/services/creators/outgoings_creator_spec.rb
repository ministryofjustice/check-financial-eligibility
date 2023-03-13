require "rails_helper"

module Creators
  RSpec.describe OutgoingsCreator do
    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary }
      let(:outgoings) { outgoings_params }
      let(:housing_cost_type_rent) { "rent" }
      let(:housing_cost_type_mortgage) { "mortgage" }

      subject(:creator) { described_class.call(assessment_id: assessment.id, outgoings_params:) }

      it "creates all the required outgoing records" do
        expect { creator }.to change(Outgoings::BaseOutgoing, :count).by(6)

        childcares = assessment.disposable_income_summary.childcare_outgoings.order(:payment_date)
        expect(childcares.first.payment_date).to eq Date.parse("2019-11-09")
        expect(childcares.first.amount.to_f).to eq 584.31
        expect(childcares.last.payment_date).to eq Date.parse("2019-12-09")
        expect(childcares.last.amount.to_f).to eq 266.95

        maintenances = assessment.disposable_income_summary.maintenance_outgoings.order(:payment_date)
        expect(maintenances.first.payment_date).to eq Date.parse("2019-11-06")
        expect(maintenances.first.amount.to_f).to eq 506.78
        expect(maintenances.last.payment_date).to eq Date.parse("2019-12-06")
        expect(maintenances.last.amount.to_f).to eq 193.47

        housings = assessment.disposable_income_summary.housing_cost_outgoings.order(:payment_date)
        expect(housings.first.payment_date).to eq Date.parse("2019-11-01")
        expect(housings.first.amount.to_f).to eq 810.38
        expect(housings.first.housing_cost_type).to eq "mortgage"
        expect(housings.last.payment_date).to eq Date.parse("2019-12-01")
        expect(housings.last.amount.to_f).to eq 299.38
        expect(housings.last.housing_cost_type).to eq "rent"
      end

      context "error in params" do
        let(:housing_cost_type_rent) { "xxxx" }

        it "doesnt create any outgoing records if there is an error" do
          expect { creator }.to raise_error ArgumentError, "'xxxx' is not a valid housing_cost_type"
          expect(Outgoings::BaseOutgoing.count).to eq 0
        end
      end

      def outgoings_params
        {
          outgoings: [
            {
              name: "child_care",
              payments: [
                { payment_date: "2019-12-09", amount: 266.95, client_id: "abc123" },
                { payment_date: "2019-11-09", amount: 584.31, client_id: "abc123" },
              ],
            },
            {
              name: "maintenance_out",
              payments: [
                { payment_date: "2019-12-06", amount: 193.47, client_id: "abc123" },
                { payment_date: "2019-11-06", amount: 506.78, client_id: "abc123" },
              ],
            },
            {
              name: "rent_or_mortgage",
              payments: [
                { payment_date: "2019-12-01", amount: 299.38, housing_cost_type: housing_cost_type_rent, client_id: "abc123" },
                { payment_date: "2019-11-01", amount: 810.38, housing_cost_type: housing_cost_type_mortgage, client_id: "abc123" },
              ],
            },
          ],
        }
      end
    end
  end
end
