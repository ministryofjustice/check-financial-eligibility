require "rails_helper"

module Calculators
  RSpec.describe PropertyCalculator do
    let(:assessment) { create :assessment, :with_capital_summary, submission_date: }
    let(:capital_summary) { assessment.capital_summary }
    let(:submission_date) { Time.zone.local(2020, 10, 10) }

    describe "#call" do
      context "main_home_only" do
        before do
          main_home.save!
          described_class.call(submission_date: assessment.submission_date,
                               properties: assessment.capital_summary.properties,
                               smod_level: 100_000,
                               level_of_representation: "certificated")
          main_home.reload
        end

        context "100% owned" do
          context "with mortgage > £100,000" do
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 266_000,
                    percentage_owned: 100.0
            end

            it "only deducts first 100k of mortgage" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 352_983.21 # 466,993 - 14,009.79 - 100,000
              expect(main_home.net_equity).to eq 352_983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 252_983.21
            end
          end

          context "when disputed" do
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 266_000,
                    percentage_owned: 100.0,
                    subject_matter_of_dispute: true
            end

            it "deducts first 100k of mortgage and 100k SMOD" do
              expect(main_home.assessed_equity).to eq 152_983.21
            end
          end

          context "with_mortgage less than 100k" do
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 37_256.44,
                    percentage_owned: 100.0
            end

            it "only deducts the actual outstanding amount" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 415_726.77 # 466,993 - 14,009.79 - 37,256.45
              expect(main_home.net_equity).to eq 415_726.77
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 315_726.77
            end
          end

          context "on or after 28th Jan 2021" do
            let(:day) { [28, 30].sample }
            let(:submission_date) { Time.zone.local(2021, 1, day) }
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 266_000,
                    percentage_owned: 100.0
            end

            it "deducts outstanding_mortgage instead of mortgage cap" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 186_983.21 # 466,993 - 14,009.79 - 266_000.0
              expect(main_home.net_equity).to eq 186_983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq BigDecimal("86_983.21", Float::DIG)
            end
          end
        end

        context "66.66% owned" do
          context "with mortgage > £100,000" do
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 266_000.44,
                    percentage_owned: 66.66
            end

            it "only deducts first 100k of mortgage" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 352_983.21 # 466,993 - 14,009.79 - 100,000
              expect(main_home.net_equity).to eq 235_298.61 # 66% of 352,983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 135_298.61
            end
          end

          context "with mortgage < £100,000" do
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 37_256.44,
                    percentage_owned: 66.66
            end

            it "only deducts the actual outstanding amount" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 415_726.77 # 466,993 - 14,009.79 - 37,256.45
              expect(main_home.net_equity).to eq 277_123.46 # 66% of 415_726.77
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 177_123.46
            end
          end

          context "on or after 28th Jan 2021" do
            let(:day) { [28, 30].sample }
            let(:submission_date) { Time.zone.local(2021, 1, day) }
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 266_000,
                    percentage_owned: 66.66
            end

            it "deducts outstanding_mortgage instead of mortgage cap" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 186_983.21 # 466,993 - 14,009.79 - 266_000.0
              expect(main_home.net_equity).to eq 124_643.01 # 66.66% of 186_983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 24_643.01
            end
          end
        end

        context "50% shared with housing association" do
          let(:main_home) do
            build :property,
                  :main_home,
                  :shared_ownership,
                  capital_summary:,
                  value: 160_000,
                  outstanding_mortgage: 70_000,
                  percentage_owned: 50.0
          end

          it "subtracts the housing association share as a %age of market value" do
            expect(main_home.transaction_allowance).to eq 4_800.0 # 3% of 160,000
            expect(main_home.net_value).to eq 85_200.0 # 160,000 - 4,800 - 70,000
            expect(main_home.net_equity).to eq 5_200.0 # 85,200.0 - (50% of 160,000)
            expect(main_home.main_home_equity_disregard).to eq 100_000.0
            expect(main_home.assessed_equity).to eq 0
          end

          context "on or after 28th Jan 2021" do
            let(:day) { [28, 30].sample }
            let(:submission_date) { Time.zone.local(2021, 1, day) }
            let(:main_home) do
              build :property,
                    :main_home,
                    :not_shared_ownership,
                    capital_summary:,
                    value: 466_993,
                    outstanding_mortgage: 266_000,
                    percentage_owned: 66.66
            end

            it "deducts outstanding_mortgage instead of mortgage cap" do
              expect(main_home.transaction_allowance).to eq 14_009.79 # 3% of 466,993
              expect(main_home.net_value).to eq 186_983.21 # 466,993 - 14,009.79 - 266_000.0
              expect(main_home.net_equity).to eq 124_643.01 # 66.66% of 186_983.21
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 24_643.01
            end
          end
        end
      end

      context "additional_properties and main dwelling" do
        let(:main_home) do
          build :property,
                :main_home,
                :not_shared_ownership,
                capital_summary:,
                value: 220_000,
                outstanding_mortgage: 35_000,
                percentage_owned: 100.0
        end

        let(:ap1) do
          build :property,
                :additional_property,
                :not_shared_ownership,
                capital_summary:,
                value: 350_000,
                outstanding_mortgage: 55_000,
                percentage_owned: 100.0
        end

        let(:ap2) do
          build :property,
                :additional_property,
                :not_shared_ownership,
                capital_summary:,
                value: 270_000,
                outstanding_mortgage: 40_000,
                percentage_owned: 100.0
        end

        before do
          [main_home, ap1, ap2].each(&:save!)
          described_class.call(submission_date: assessment.submission_date,
                               smod_level: 0,
                               properties: assessment.capital_summary.properties,
                               level_of_representation: "certificated")
          [main_home, ap1, ap2].each(&:reload)
        end

        context "main dwelling wholly owned and additional properties wholly owned" do
          let(:additional_properties) do
            [ap1, ap2].map do |ap|
              ap.attributes.symbolize_keys
                .except(:id, :created_at, :updated_at, :capital_summary_id,
                        :main_home, :shared_with_housing_assoc,
                        :subject_matter_of_dispute,
                        :value, :outstanding_mortgage, :percentage_owned)
            end
          end

          it "deducts a maximum of £100k mortgage over all properties" do
            expect(additional_properties.each_with_object(Hash.new(0)) { |ap, h| ap.each { |k, v| h[k] += v } })
              .to eq({ transaction_allowance: 18_600.0,
                       net_value: 536_400.0,
                       net_equity: 536_400.0,
                       main_home_equity_disregard: 0.0,
                       assessed_equity: 536_400.0 })
            expect(main_home.attributes.symbolize_keys
                            .except(:id, :created_at, :updated_at, :capital_summary_id,
                                    :main_home, :shared_with_housing_assoc,
                                    :subject_matter_of_dispute,
                                    :value, :outstanding_mortgage, :percentage_owned))
              .to eq({ transaction_allowance: 6_600.0,
                       net_value: 178_400.0,
                       net_equity: 178_400.0,
                       main_home_equity_disregard: 100_000.0,
                       assessed_equity: 78_400.0 })
          end

          context "on or after 28th Jan 2021" do
            let(:day) { [28, 30].sample }
            let(:submission_date) { Time.zone.local(2021, 1, day) }

            it "deducts outstanding_mortgage instead of mortgage cap" do
              expect(ap1.transaction_allowance).to eq 10_500.0
              expect(ap1.net_value).to eq 284_500.0
              expect(ap1.net_equity).to eq 284_500.0
              expect(ap1.main_home_equity_disregard).to eq 0.0
              expect(ap1.assessed_equity).to eq 284_500.0

              expect(ap2.transaction_allowance).to eq 8_100.0
              expect(ap2.net_value).to eq 221_900.0
              expect(ap2.net_equity).to eq 221_900.0
              expect(ap2.main_home_equity_disregard).to eq 0.0
              expect(ap2.assessed_equity).to eq 221_900.0

              expect(main_home.transaction_allowance).to eq 6_600.0
              expect(main_home.net_value).to eq 178_400.0
              expect(main_home.net_equity).to eq 178_400.0
              expect(main_home.main_home_equity_disregard).to eq 100_000.0
              expect(main_home.assessed_equity).to eq 78_400.0
            end
          end
        end
      end

      context "additional property but no main dwelling" do
        let(:additional_property) do
          build :property,
                :additional_property,
                :not_shared_ownership,
                capital_summary:,
                value: 350_000,
                outstanding_mortgage: 55_000,
                percentage_owned: 100.0
        end

        before do
          additional_property.save!
          described_class.call(submission_date: assessment.submission_date,
                               smod_level: 0,
                               properties: assessment.capital_summary.properties,
                               level_of_representation: "certificated")
          additional_property.reload
        end

        it "calculates the additional property correctly" do
          expect(additional_property.transaction_allowance).to eq 10_500.0
          expect(additional_property.net_value).to eq 284_500.0
          expect(additional_property.net_equity).to eq 284_500.0
          expect(additional_property.main_home_equity_disregard).to eq 0.0
          expect(additional_property.assessed_equity).to eq 284_500.0
          expect(capital_summary.main_home).to be_nil
        end

        context "on or after 28th Jan 2021" do
          let(:day) { [28, 30].sample }
          let(:submission_date) { Time.zone.local(2021, 1, day) }
          let(:additional_property) do
            build :property,
                  :additional_property,
                  :not_shared_ownership,
                  capital_summary:,
                  value: 350_000,
                  outstanding_mortgage: 200_000,
                  percentage_owned: 100.0
          end

          it "deducts outstanding_mortgage instead of mortgage cap" do
            expect(additional_property.transaction_allowance).to eq 10_500.0
            expect(additional_property.net_value).to eq 139_500.0
            expect(additional_property.net_equity).to eq 139_500.0
            expect(additional_property.main_home_equity_disregard).to eq 0.0
            expect(additional_property.assessed_equity).to eq 139_500.0
            expect(capital_summary.main_home).to be_nil
          end
        end
      end
    end
  end
end
