require Rails.root.join("lib/integration_helpers/test_case/v4/remarks_comparer")
require "rails_helper"

module TestCase
  module V4
    RSpec.describe RemarksComparer do
      let(:actual) { full_results }
      let(:verbosity) { 0 }

      subject(:service) { described_class.call(expected, actual, verbosity) }

      context "when expected remarks is nil" do
        let(:expected) { nil }

        it "returns true" do
          expect(service).to be true
        end
      end

      context "when expected is empty" do
        let(:expected) { {} }

        it "returns true" do
          expect(service).to be true
        end
      end

      context "when expected matches actual" do
        let(:expected) { full_results }

        it "returns true" do
          expect(service).to be true
        end
      end

      context "when expected does not match actual" do
        let(:expected) { unexpected_results }

        it "returns false" do
          expect(service).to be false
        end
      end

      context "when expected partially matches actual" do
        let(:actual) { partial_results }
        let(:expected) { full_results }

        it "returns false" do
          expect(service).to be false
        end
      end

      context "when actual is nil " do
        let(:actual) { nil }
        let(:expected) { full_results }

        it "returns false" do
          expect(service).to be false
        end
      end

      context "when actual is an empty hash " do
        let(:actual) { {} }
        let(:expected) { full_results }

        it "returns false" do
          expect(service).to be false
        end
      end

      def full_results
        {
          employment: {
            multiple_employments: %w[
              job-1
              job-2
            ],
          },
          employment_tax: {
            refund: %w[
              payment-1
              payment-2
            ],
          },
        }
      end

      def unexpected_results
        {
          employment: {
            multiple_employments: %w[
              job-7
              job-7
            ],
          },
          employment_tax: {
            refund: %w[
              payment-8
              payment-8
            ],
          },
        }
      end

      def partial_results
        {
          employment_tax: {
            refund: %w[
              payment-1
              payment-2
            ],
          },
        }
      end
    end
  end
end
