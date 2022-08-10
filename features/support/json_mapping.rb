# Defines the mapping of various values based on version of the API.
# This will provide a simple way to assert values present in the API response differently for each version.
def mapping
	{
		'v5' => {
			'assessment_result' => 'result_summary.overall_result.result',
			'disposable_income_summary' => 'result_summary.disposable_income',
			'capital_lower_threshold' => 'result_summary.capital.proceeding_types.0.lower_threshold',
			'gross_income_upper_threshold' => 'result_summary.gross_income.proceeding_types.1.upper_threshold',
			'gross_income_proceeding_types' => 'result_summary.gross_income.proceeding_types'
		}
	}
end
