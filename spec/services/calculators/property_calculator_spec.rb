require "rails_helper"

module Calculators
  RSpec.describe PropertyCalculator do
    let(:assessment) { create :assessment, :with_capital_summary, submission_date: }
    let(:capital_summary) { assessment.capital_summary }
    let(:submission_date) { Time.zone.local(2020, 10, 10) }

    describe "#call" do
      let(:properties) do
        described_class.call(submission_date: assessment.submission_date,
                             properties: assessment.capital_summary.properties,
                             smod_level: 100_000,
                             level_of_help: "certificated")
      end

      context "main_home_only" do
        before do
          main_home.save!
        end

        let(:result) do
          properties.detect(&:main_home)
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
              expect(result)
                .to have_attributes({
                  transaction_allowance: 14_009.79, # 3% of 466,993
                  net_value: 352_983.21, # 466,993 - 14,009.79 - 100,000
                  net_equity: 352_983.21,
                  main_home_equity_disregard: 100_000.0,
                  assessed_equity: 252_983.21,
                })
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
              expect(result.assessed_equity).to eq 152_983.21
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
              expect(result)
                .to have_attributes({ transaction_allowance: 14_009.79, # 3% of 466,993
                                      net_value: 415_726.77, # 466,993 - 14,009.79 - 37,256.45
                                      net_equity: 415_726.77,
                                      main_home_equity_disregard: 100_000.0,
                                      assessed_equity: 315_726.77 })
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
              expect(result)
                .to have_attributes({ transaction_allowance: 14_009.79, # 3% of 466,993
                                      net_value: 186_983.21, # 466,993 - 14,009.79 - 266_000.0
                                      net_equity: 186_983.21,
                                      main_home_equity_disregard: 100_000.0 })
              expect(result.assessed_equity).to eq BigDecimal("86_983.21", Float::DIG)
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
              expect(result)
                .to have_attributes({ transaction_allowance: 14_009.79, # 3% of 466,993
                                      net_value: 352_983.21, # 466,993 - 14,009.79 - 100,000
                                      net_equity: 235_298.61, # 66% of 352,983.21
                                      main_home_equity_disregard: 100_000.0,
                                      assessed_equity: 135_298.61 })
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
              expect(result)
                .to have_attributes({ transaction_allowance: 14_009.79, # 3% of 466,993
                                      net_value: 415_726.77, # 466,993 - 14,009.79 - 37,256.45
                                      net_equity: 277_123.46, # 66% of 415_726.77
                                      main_home_equity_disregard: 100_000.0,
                                      assessed_equity: 177_123.46 })
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
              expect(result)
                .to have_attributes({ transaction_allowance: 14_009.79, # 3% of 466,993
                                      net_value: 186_983.21, # 466,993 - 14,009.79 - 266_000.0
                                      net_equity: 124_643.01, # 66.66% of 186_983.21
                                      main_home_equity_disregard: 100_000.0,
                                      assessed_equity: 24_643.01 })
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
            expect(result)
              .to have_attributes(
                { transaction_allowance: 4_800.0, # 3% of 160,000
                  net_value: 85_200.0, # 160,000 - 4,800 - 70,000
                  net_equity: 5_200.0, # 85,200.0 - (50% of 160,000)
                  main_home_equity_disregard: 100_000.0,
                  assessed_equity: 0 },
              )
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
              expect(result)
                .to have_attributes(
                  { transaction_allowance: 14_009.79, # 3% of 466,993
                    net_value: 186_983.21, # 466,993 - 14,009.79 - 266_000.0
                    net_equity: 124_643.01, # 66.66% of 186_983.21
                    main_home_equity_disregard: 100_000.0,
                    assessed_equity: 24_643.01 },
                )
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
        let(:additional_properties) do
          properties.reject(&:main_home).map(&:to_h).map { |c| c.except(:property) }
        end
        let(:main_home_result) { properties.detect(&:main_home) }
        let(:ap1_result) { properties.detect { |p| p.value == 350_000 } }
        let(:ap2_result) { properties.detect { |p| p.value == 270_000 } }

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
        end

        context "main dwelling wholly owned and additional properties wholly owned" do
          it "deducts a maximum of £100k mortgage over all properties" do
            expect(additional_properties.each_with_object(Hash.new(0)) { |ap, h| ap.each { |k, v| h[k] += v } })
              .to eq({ transaction_allowance: 18_600.0,
                       net_value: 536_400.0,
                       smod_allowance: 0,
                       net_equity: 536_400.0,
                       main_home_equity_disregard: 0.0,
                       assessed_equity: 536_400.0 })
            expect(main_home_result.to_h.except(:property))
              .to eq({ transaction_allowance: 6_600.0,
                       net_value: 178_400.0,
                       net_equity: 178_400.0,
                       smod_allowance: 0,
                       main_home_equity_disregard: 100_000.0,
                       assessed_equity: 78_400.0 })
          end

          context "on or after 28th Jan 2021" do
            let(:day) { [28, 30].sample }
            let(:submission_date) { Time.zone.local(2021, 1, day) }

            it "deducts outstanding_mortgage instead of mortgage cap" do
              expect(ap1_result)
                .to have_attributes(
                  { transaction_allowance: 10_500.0,
                    net_value: 284_500.0,
                    net_equity: 284_500.0,
                    main_home_equity_disregard: 0.0,
                    assessed_equity: 284_500.0 },
                )

              expect(ap2_result)
                .to have_attributes(
                  { transaction_allowance: 8_100.0,
                    net_value: 221_900.0,
                    net_equity: 221_900.0,
                    main_home_equity_disregard: 0.0,
                    assessed_equity: 221_900.0 },
                )

              expect(main_home_result)
                .to have_attributes(
                  { transaction_allowance: 6_600.0,
                    net_value: 178_400.0,
                    net_equity: 178_400.0,
                    main_home_equity_disregard: 100_000.0,
                    assessed_equity: 78_400.0 },
                )
            end
          end
        end
      end

      context "additional property but no main dwelling" do
        let(:ap1) do
          build :property,
                :additional_property,
                :not_shared_ownership,
                capital_summary:,
                value: 350_000,
                outstanding_mortgage: 55_000,
                percentage_owned: 100.0
        end
        let(:additional_property) { properties.first }

        before do
          ap1.save!
        end

        it "calculates the additional property correctly" do
          expect(additional_property)
            .to have_attributes(transaction_allowance: 10_500.0,
                                net_value: 284_500.0,
                                net_equity: 284_500.0,
                                main_home_equity_disregard: 0.0,
                                assessed_equity: 284_500.0)
          expect(capital_summary.main_home).to be_nil
        end

        context "on or after 28th Jan 2021" do
          let(:day) { [28, 30].sample }
          let(:submission_date) { Time.zone.local(2021, 1, day) }
          let(:ap1) do
            build :property,
                  :additional_property,
                  :not_shared_ownership,
                  capital_summary:,
                  value: 350_000,
                  outstanding_mortgage: 200_000,
                  percentage_owned: 100.0
          end

          it "deducts outstanding_mortgage instead of mortgage cap" do
            expect(additional_property)
              .to have_attributes(transaction_allowance: 10_500.0,
                                  net_value: 139_500.0,
                                  net_equity: 139_500.0,
                                  main_home_equity_disregard: 0.0,
                                  assessed_equity: 139_500.0)
            expect(capital_summary.main_home).to be_nil
          end
        end
      end
    end
  end
end
