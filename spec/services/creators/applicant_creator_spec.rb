require "rails_helper"

module Creators
  RSpec.describe ApplicantCreator do
    describe "POST applicant" do
      let(:assessment) { create :assessment }
      let(:date_of_birth) { Faker::Date.backward.to_s }
      let(:applicant_params) do
        {
          applicant: {
            date_of_birth:,
            involvement_type: "applicant",
            has_partner_opponent: true,
            receives_qualifying_benefit: true,
            receives_asylum_support: true,
          },
        }
      end

      subject(:creator) { described_class.call(assessment:, applicant_params:) }

      describe ".call" do
        context "valid payload" do
          describe "#success?" do
            it "returns true" do
              expect(creator.success?).to be true
            end

            it "creates an applicant" do
              expect { creator.success? }.to change(Applicant, :count).by 1
            end
          end

          describe "#applicant" do
            it "returns the applicant" do
              expect(creator.applicant).to be_a Applicant
            end
          end

          describe "#errors" do
            it "is empty" do
              expect(creator.errors).to be_empty
            end
          end
        end

        context "ActiveRecord validation fails" do
          context "date of birth cannot be in future" do
            let(:date_of_birth) { Date.tomorrow.to_date.to_s }

            describe "#success?" do
              it "returns false" do
                expect(creator.success?).to be false
              end
            end

            describe "#applicant" do
              it "returns empty array" do
                expect(creator.applicant).to be_nil
              end
            end

            describe "#errors" do
              it "returns error" do
                expect(creator.errors.size).to eq 1
                expect(creator.errors[0]).to eq "Date of birth cannot be in future"
              end
            end

            it "does not create an applicant" do
              expect { creator }.not_to change(Applicant, :count)
            end
          end

          context "applicant already exists" do
            before { create :applicant, assessment: }

            describe "#success?" do
              it "returns false" do
                expect(creator.success?).to be false
              end
            end

            describe "#applicant" do
              it "returns empty array" do
                expect(creator.applicant).to be_nil
              end
            end

            it "does not create an applicant" do
              expect { creator }.not_to change(Applicant, :count)
            end

            describe "#errors" do
              it "returns error" do
                expect(creator.errors[0]).to eq "There is already an applicant for this assesssment"
              end
            end
          end
        end
      end
    end
  end
end
