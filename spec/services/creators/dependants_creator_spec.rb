require "rails_helper"

module Creators
  RSpec.describe DependantsCreator do
    include Rails.application.routes.url_helpers
    let(:assessment) { create :assessment }
    let(:dependants_attributes) { attributes_for_list(:dependant, 2).map { |v| v.merge(date_of_birth: v.fetch(:date_of_birth).to_s) } }
    let(:dependants_params) { { dependants: dependants_attributes } }

    subject(:creator) { described_class.call(dependants: assessment.dependants, dependants_params:) }

    context "valid payload" do
      it "creates two dependant records for this assessment" do
        expect { creator }.to change { assessment.dependants.count }.by(dependants_attributes.count)

        dependants_attributes.each do |dependant_attributes|
          dependant = assessment.dependants.find_by!(date_of_birth: dependant_attributes[:date_of_birth])
          dependant_attributes.each_key do |key|
            expect(dependant[key].to_s).to eq(dependant_attributes[key].to_s),
                                           "Dependent attribute `#{key}` mismatch: #{dependant[key].inspect}, #{dependant_attributes[key].inspect}"
          end
        end
      end

      describe "#success?" do
        it "returns true" do
          expect(creator).to be_success
        end
      end

      describe "#dependants" do
        before do
          creator
        end

        let(:result) { Dependant.all }

        it "returns the created dependants" do
          expect(result.count).to eq(dependants_attributes.count)
          expect(result.first).to be_a(Dependant)
          expect(result.first.assessment.id).to eq(assessment.id)
        end
      end
    end

    context "payload fails ActiveRecord validations" do
      let(:dependants_attributes) { attributes_for_list(:dependant, 2, date_of_birth: Faker::Date.forward.to_s) }

      describe "#success?" do
        it "returns false" do
          expect(creator.success?).to be false
        end

        it "does not create a Dependant record" do
          expect { creator }.not_to change(Dependant, :count)
        end
      end

      describe "errors" do
        it "returns an error payload" do
          expect(creator.errors.size).to eq 1
          expect(creator.errors).to include "Date of birth cannot be in future"
        end
      end
    end
  end
end
