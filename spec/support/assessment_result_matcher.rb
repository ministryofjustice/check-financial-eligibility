RSpec::Matchers.define :have_main_assessment_result do |assessment, expected_main_assessment|
  match do |summary_assessments|
    gross_income_result, disposable_income_result, capital_result = summary_assessments
    allow_any_instance_of(assessment.gross_income_summary.class).to receive(:summarized_assessment_result).and_return(gross_income_result)
    allow_any_instance_of(assessment.disposable_income_summary.class).to receive(:summarized_assessment_result).and_return(disposable_income_result)
    allow_any_instance_of(assessment.capital_summary.class).to receive(:summarized_assessment_result).and_return(capital_result)
    Assessors::MainAssessor.call(assessment)
    assessment.reload.assessment_result == expected_main_assessment
  end

  failure_message do |summary_assessments|
    gross_income_result, disposable_income_result, capital_result = summary_assessments
    string = 'Unexpected main assessment result'
    string += "\n   Gross income: #{gross_income_result}"
    string += "\n   Disposable income: #{disposable_income_result}"
    string += "\n   Capital income: #{capital_result}"
    string += "\n\nExpected #{expected_main_assessment}, got #{assessment.assessment_result}"
    string
  end
end

RSpec::Matchers.define :have_assessment_error do |assessment, message|
  match do |summary_assessments|
    gross_income_result, disposable_income_result, capital_result = summary_assessments
    allow_any_instance_of(assessment.gross_income_summary.class).to receive(:summarized_assessment_result).and_return(gross_income_result)
    allow_any_instance_of(assessment.disposable_income_summary.class).to receive(:summarized_assessment_result).and_return(disposable_income_result)
    allow_any_instance_of(assessment.capital_summary.class).to receive(:summarized_assessment_result).and_return(capital_result)
    @error_raised = false
    begin
      Assessors::MainAssessor.call(assessment)
      false
    rescue StandardError => @err
      @error_raised = true
      @err.message == message
    end
  end

  failure_message do |summary_assessments|
    gross_income_result, disposable_income_result, capital_result = summary_assessments
    string = 'Expected exception not raised'
    string += "\n   Gross income: #{gross_income_result}"
    string += "\n   Disposable income: #{disposable_income_result}"
    string += "\n   Capital income: #{capital_result}"
    string += "\n\nExpected AssessmentError with message '#{message}'"

    string += if @error_raised
                "\nGot #{@err.class} with message: '#{@err.message}'"
              else
                "\nNo exception raised"
              end

    string
  end
end
