require 'rails_helper'

RSpec.describe Threshold do
  let(:threshold_test_data_folder) { Rails.root.join('spec/data/thresholds') }

  describe '.value_for' do
    around do |example|
      Threshold.data_folder_path = threshold_test_data_folder
      example.run
      Threshold.data_folder_path = nil
    end

    let(:time) { Time.zone.parse('9-June-2019 12:35') }
    let(:test_data_file) { "#{threshold_test_data_folder}/8-Apr-2019.yml" }
    let(:data) { YAML.load_file(test_data_file).deep_symbolize_keys }

    it 'returns the expected value' do
      expect(Threshold.value_for(:capital_lower, at: time)).to eq(data[:capital_lower])
    end

    context 'for dates before oldest' do
      let(:time) { Time.zone.parse('9-June-2001 12:35') }
      let(:path) { data_file_path('thresholds/8-Apr-2018.yml') }
      let(:data) { YAML.load_file("#{threshold_test_data_folder}/8-Apr-2018.yml").deep_symbolize_keys }

      it 'returns the value from oldest file' do
        expect(Threshold.value_for(:capital_lower, at: time)).to eq(data[:capital_lower])
      end
    end

    context 'file is marked as test_only: true' do
      context "ENV['USE_TEST_THRESHOLD_DATA'] is set to 'true'" do
        around do |example|
          ENV['USE_TEST_THRESHOLD_DATA'] = 'true'
          example.run
          ENV['USE_TEST_THRESHOLD_DATA'] = nil
        end

        context 'date before date of test only file' do
          let(:time) { Time.zone.parse('1-Dec-2020 12:33') }
          it 'returns value from the April 2020 file' do
            expect(Threshold.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 666_666_666_666
          end
        end

        context 'date after date of test only file' do
          let(:time) { Time.zone.parse('15-Dec-2020 11:48') }
          it 'returns mortgage allowance Test file' do
            expect(Threshold.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 888_888_888_888
          end
        end

        context 'date after most recent file' do
          let(:time) { Time.zone.parse('1-Jan-2030 12:33') }
          it 'returns value from the Jan 2021 file' do
            expect(Threshold.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 999_999_999_999
          end
        end
      end

      context "ENV['USE_TEST_THRESHOLD_DATA'] is absent" do
        context 'date before date of test only file' do
          let(:time) { Time.zone.parse('1-Dec-2020 12:33') }
          it 'returns value from the April 2020 file' do
            expect(Threshold.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 666_666_666_666
          end
        end

        context 'date after date of test only file' do
          let(:time) { Time.zone.parse('15-Dec-2020 11:48') }
          it 'returns value from the April 2020 file' do
            expect(Threshold.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 666_666_666_666
          end
        end

        context 'date after most recent file' do
          let(:time) { Time.zone.parse('1-Jan-2030 12:33') }
          it 'returns value from the Jan 2021 file' do
            expect(Threshold.value_for(:property_maximum_mortgage_allowance, at: time)).to eq 999_999_999_999
          end
        end
      end
    end
  end
end
