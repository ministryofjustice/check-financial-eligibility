require "rails_helper"

RSpec.describe Threshold do
  context "using test data files" do
    let(:threshold_test_data_folder) { Rails.root.join("spec/data/thresholds") }

    describe ".value_for" do
      around do |example|
        described_class.data_folder_path = threshold_test_data_folder
        example.run
        described_class.data_folder_path = nil
      end

      let(:time) { Time.zone.parse("9-June-2019 12:35") }
      let(:test_data_file) { "#{threshold_test_data_folder}/2019-04-08.yml" }
      let(:data) { YAML.load_file(test_data_file).deep_symbolize_keys }

      it "returns the expected value" do
        expect(described_class.value_for(:capital_lower_certificated, at: time)).to eq(data[:capital_lower_certificated])
      end

      context "for dates before oldest" do
        let(:time) { Time.zone.parse("9-June-2001 12:35") }
        let(:path) { data_file_path("thresholds/8-Apr-2018.yml") }
        let(:data) { YAML.load_file("#{threshold_test_data_folder}/2018-04-08.yml").deep_symbolize_keys }

        it "returns the value from oldest file" do
          expect(described_class.value_for(:capital_lower_certificated, at: time)).to eq(data[:capital_lower_certificated])
        end
      end

      context "file is marked as test_only: true" do
        context "ENV['USE_TEST_THRESHOLD_DATA'] is set to 'true'" do
          before { allow(Rails.configuration.x).to receive(:use_test_threshold_data).and_return("true") }

          context "date before date of test only file" do
            let(:time) { Time.zone.parse("1-Dec-2020 12:33") }

            it "returns value from the April 2020 file" do
              expect(described_class.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 666_666_666_666
            end
          end

          context "date after date of test only file" do
            let(:time) { Time.zone.parse("15-Dec-2020 11:48") }

            it "returns mortgage allowance Test file" do
              expect(described_class.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 888_888_888_888
            end
          end

          context "date after most recent file" do
            let(:time) { Time.zone.parse("1-Jan-2030 12:33") }

            it "returns value from the Jan 2021 file" do
              expect(described_class.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 999_999_999_999
            end
          end
        end

        context "ENV['USE_TEST_THRESHOLD_DATA'] is absent" do
          context "date before date of test only file" do
            let(:time) { Time.zone.parse("1-Dec-2020 12:33") }

            it "returns value from the April 2020 file" do
              expect(described_class.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 666_666_666_666
            end
          end

          context "date after date of test only file" do
            let(:time) { Time.zone.parse("15-Dec-2020 11:48") }

            it "returns value from the April 2020 file" do
              expect(described_class.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 666_666_666_666
            end
          end

          context "date after most recent file" do
            let(:time) { Time.zone.parse("1-Jan-2030 12:33") }

            it "returns value from the Jan 2021 file" do
              expect(described_class.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 999_999_999_999
            end
          end
        end
      end
    end
  end

  context "using live files" do
    context "before 2020-04-06" do
      let(:time) { Time.zone.parse("01-Apr-2020") }
      let(:expected_dependant_allowances) do
        {
          child_under_15: 291.49,
          child_aged_15: 291.49,
          child_16_and_over: 291.49,
          adult: 291.49,
          adult_capital_threshold: 8_000,
        }
      end

      it "retrieves values from the 2019-04-08 file" do
        expect(described_class.value_for(:dependant_allowances, at: time)).to eq expected_dependant_allowances
      end
    end

    context "on 2020-04-06" do
      let(:time) { Time.zone.parse("06-Apr-2020") }
      let(:expected_dependant_allowances) do
        {
          child_under_15: 296.65,
          child_aged_15: 296.65,
          child_16_and_over: 296.65,
          adult: 296.65,
          adult_capital_threshold: 8_000,
        }
      end

      it "picks up the values from the 2020-04-06 file" do
        expect(described_class.value_for(:dependant_allowances, at: time)).to eq expected_dependant_allowances
      end
    end
  end
end
