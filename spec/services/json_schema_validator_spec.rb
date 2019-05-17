require 'rails_helper'
require_relative '../fixtures/assessment_fixture'

describe JsonSchemaValidator do
  let(:assessment_hash) { AssessmentFixture.ruby_hash }
  let(:payload) { JSON.pretty_generate(assessment_hash) }
  let(:validator) { JsonSchemaValidator.new(payload) }

  context 'valid assessment payloads' do
    context 'unchanged payload' do
      it 'is valid' do
        validator.run
        expect(validator.valid?).to be true
      end
    end

    context 'client_referenc_id' do
      context 'missing' do
        before do
          assessment_hash.delete(:client_reference_id)
          validator.run
        end

        it 'is valid' do
          expect(validator).to be_valid
        end
      end
    end

    context 'root' do
      context 'extra property' do
        before do
          assessment_hash['added_property'] = 33
          validator.run
        end

        it 'is not valid' do
          expect(validator).not_to be_valid
        end

        it 'shows an error message' do
          expected_error = "The property '#/' contains additional properties.*added_property"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'missing property' do
        before do
          assessment_hash.delete(:applicant)
          validator.run
        end

        it 'is not valid' do
          expect(validator).not_to be_valid
        end

        it 'shows an error message' do
          expected_error = "The property '#/' did not contain a required property of 'applicant'"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end
    end

    context 'applicant' do
      context 'date of birth' do
        context 'missing' do
          before do
            assessment_hash[:applicant].delete(:date_of_birth)
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant' did not contain a required property of 'date_of_birth'"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'invalid' do
          before do
            assessment_hash[:applicant][:date_of_birth] = '24-03-1966'
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant/date_of_birth' value \"24-03-1966\" did not match the regex"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end
      end

      context 'additional property' do
        before do
          assessment_hash[:applicant][:mother_in_law] = true
          validator.run
        end

        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error' do
          expected_error = "The property '#/applicant' contains additional properties .*mother_in_law"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'dependents' do
        context 'none specified' do
          before do
            assessment_hash[:applicant].delete(:dependents)
            validator.run
          end
        end

        it 'is valid' do
          expect(validator).to be_valid
        end

        context 'missing attribute' do
          before do
            assessment_hash[:applicant][:dependents].first.delete(:in_full_time_education)
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant/dependents/0' did not contain a required property of 'in_full_time_education'"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'extra attribute' do
          before do
            assessment_hash[:applicant][:dependents].last[:name] = 'Joe'
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant/dependents/1' contains additional properties .*name"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end
      end
    end

    context 'applicant_income' do
      context 'wage slips' do
        context 'no wage_slips specified' do
          before do
            assessment_hash[:applicant_income].delete(:wage_slips)
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end

        context 'wage slip has missing property' do
          before do
            assessment_hash[:applicant_income][:wage_slips].last.delete(:paye)
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_income/wage_slips/1' did not contain a required property of 'paye'"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end
      end

      context 'wage slip has an extra unknown property' do
        before do
          assessment_hash[:applicant_income][:wage_slips].first[:bonus] = true
          validator.run
        end

        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error message' do
          expected_error = "The property '#/applicant_income/wage_slips/0' contains additional properties .*bonus"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'benefits' do
        context 'no benefits specified' do
          before do
            assessment_hash[:applicant_income].delete(:benefits)
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end

        context 'additional unknown property' do
          before do
            assessment_hash[:applicant_income][:benefits].first[:xxxx] = true
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_income/benefits/0' contains additional properties .*xxxx"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'missing property' do
          before do
            assessment_hash[:applicant_income][:benefits].first.delete(:benefit_name)
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_income/benefits/0' did not contain a required property of 'benefit_name'"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end
      end
    end

    context 'applicant outgoings' do
      context 'not present' do
        before do
          assessment_hash.delete(:applicant_outgoings)
          validator.run
        end
        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error message' do
          expected_error = "The property '#/' did not contain a required property of 'applicant_outgoings'"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'there is not one outgoing' do
        before do
          assessment_hash[:applicant_outgoings] = []
          validator.run
        end

        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error message' do
          expected_error = "The property '#/applicant_outgoings' did not contain a minimum number of items 1"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'an attribute is missing' do
        before do
          assessment_hash[:applicant_outgoings].first.delete(:type_of_outgoing)
          validator.run
        end

        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error message' do
          expected_error = "The property '#/applicant_outgoings/0' did not contain a required property of 'type_of_outgoing'"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'it has an extra unknown attribute' do
        before do
          assessment_hash[:applicant_outgoings].first[:xxxx] = false
          validator.run
        end

        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error message' do
          expected_error = "The property '#/applicant_outgoings/0' contains additional properties .*xxxx"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'type of outgoing' do
        context 'a value not in the permitted list of values' do
          before do
            assessment_hash[:applicant_outgoings].first[:type_of_outgoing] = 'loan to a friend'
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_outgoings/0/type_of_outgoing' value .*loan to a friend.* did not match one of the following values: mortgage, maintenance"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end
      end

      context 'amount' do
        context 'amount is not numeric' do
          before do
            assessment_hash[:applicant_outgoings].first[:amount] = 'ten point 3'
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_outgoings/0/amount' of type string did not match the following type: number"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'amount is an integer' do
          before do
            assessment_hash[:applicant_outgoings].first[:amount] = 354
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end

        context 'amount has thee decimal places' do
          before do
            assessment_hash[:applicant_outgoings].first[:amount] = 153.667
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_outgoings/0/amount' was not divisible by 0.01"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'amount is negative' do
          before do
            assessment_hash[:applicant_outgoings].first[:amount] = -455.23
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_outgoings/0/amount' did not have a minimum value of 0.01"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'amount is a positive two decimal number' do
          before do
            assessment_hash[:applicant_outgoings].first[:amount] = 754.22
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end
      end
    end

    context 'applicant_capital' do
      context 'an additional unknown property is present' do
        before do
          assessment_hash[:applicant_capital][:trust_fund] = 'BVI'
          validator.run
        end

        it 'is invalid' do
          expect(validator).not_to be_valid
        end

        it 'has an error message' do
          expected_error = "The property '#/applicant_capital' contains additional properties .*trust_fund"
          expect(validator.errors.first).to match(/#{expected_error}/)
        end
      end

      context 'property' do
        context 'it is not present' do
          before do
            assessment_hash[:applicant_capital].delete(:property)
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end

        context 'an extra unknown attribute is present' do
          before do
            assessment_hash[:applicant_capital][:property][:holiday_let] = 'France'
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_capital/property' contains additional properties .*holiday_let"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'main_home' do
          context 'it is not present' do
            before do
              assessment_hash[:applicant_capital][:property].delete(:main_home)
              validator.run
            end

            it 'is valid' do
              expect(validator).to be_valid
            end
          end

          context 'it has an extra attribute' do
            before do
              assessment_hash[:applicant_capital][:property][:main_home][:purchase_price] = 12_000
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/property/main_home' contains additional properties .*purchase_price"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end

          context 'it has a missing attribute' do
            before do
              assessment_hash[:applicant_capital][:property][:main_home].delete(:value)
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/property/main_home' did not contain a required property of 'value'"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end
        end

        context 'other properties' do
          context 'it is not present' do
            before do
              assessment_hash[:applicant_capital][:property].delete(:other_properties)
              validator.run
            end

            it 'is valid' do
              expect(validator).to be_valid
            end
          end

          context 'it has an extra attribute' do
            before do
              assessment_hash[:applicant_capital][:property][:other_properties].first[:purchase_price] = 12_000
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/property/other_properties/0' contains additional properties .*purchase_price"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end

          context 'it has a missing attribute' do
            before do
              assessment_hash[:applicant_capital][:property][:other_properties].first.delete(:value)
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/property/other_properties/0' did not contain a required property of 'value'"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end
        end
      end

      context 'liquid_capital' do
        context 'it is not present' do
          before do
            assessment_hash[:applicant_capital].delete(:liquid_capital)
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end

        context 'valuable_items' do
          context 'it is not present' do
            before do
              assessment_hash[:applicant_capital][:liquid_capital].delete(:valuable_items)
              validator.run
            end

            it 'is valid' do
              expect(validator).to be_valid
            end
          end

          context 'it has an extra attribute' do
            before do
              assessment_hash[:applicant_capital][:liquid_capital][:valuable_items].first[:name] = 'Michael'
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/liquid_capital/valuable_items/0' contains additional properties .*name"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end

          context 'it has a missing attribute' do
            before do
              assessment_hash[:applicant_capital][:liquid_capital][:valuable_items].first.delete(:value)
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/liquid_capital/valuable_items/0' did not contain a required property of 'value'"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end
        end

        context 'vehicles' do
          context 'it is not present' do
            before do
              assessment_hash[:applicant_capital][:liquid_capital].delete(:vehicles)
              validator.run
            end

            it 'is valid' do
              expect(validator).to be_valid
            end
          end

          context 'it has an extra attribute' do
            before do
              assessment_hash[:applicant_capital][:liquid_capital][:vehicles].first[:name] = 'Michael'
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/liquid_capital/vehicles/0' contains additional properties .*name"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end

          context 'it has a missing attribute' do
            before do
              assessment_hash[:applicant_capital][:liquid_capital][:vehicles].first.delete(:value)
              validator.run
            end

            it 'is invalid' do
              expect(validator).not_to be_valid
            end

            it 'has an error message' do
              expected_error = "The property '#/applicant_capital/liquid_capital/vehicles/0' did not contain a required property of 'value'"
              expect(validator.errors.first).to match(/#{expected_error}/)
            end
          end
        end
      end

      context 'non_liquid_capital' do
        context 'it is not present' do
          before do
            assessment_hash[:applicant_capital].delete(:non_liquid_capital)
            validator.run
          end

          it 'is valid' do
            expect(validator).to be_valid
          end
        end
        context 'it has an extra attribute' do
          before do
            assessment_hash[:applicant_capital][:non_liquid_capital].first[:name] = 'Michael'
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_capital/non_liquid_capital/0' contains additional properties .*name"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end

        context 'it has a missing attribute' do
          before do
            assessment_hash[:applicant_capital][:non_liquid_capital].first.delete(:value)
            validator.run
          end

          it 'is invalid' do
            expect(validator).not_to be_valid
          end

          it 'has an error message' do
            expected_error = "The property '#/applicant_capital/non_liquid_capital/0' did not contain a required property of 'value'"
            expect(validator.errors.first).to match(/#{expected_error}/)
          end
        end
      end
    end
  end
end
