# Holds all route details for the API.
class Routes
	attr_reader :collection

	def initialize
		@collection = {
			create_assessment: {:method => "post", :uri => "/assessments"},
			add_applicant: {:method => "post", :uri => "/assessments/{id}/applicant"},
			add_dependants: {:method => "post", :uri => "/assessments/{id}/dependants"},
			add_other_incomes: {:method => "post", :uri => "/assessments/{id}/other_incomes"},
			add_irregular_incomes: {:method => "post", :uri => "/assessments/{id}/irregular_incomes"},
			add_outgoings: {:method => "post", :uri => "/assessments/{id}/outgoings"},
			add_capitals: {:method => "post", :uri => "/assessments/{id}/capitals"},
			add_proceeding_types: {:method => "post", :uri => "/assessments/{id}/proceeding_types"},
			retrieve_assessment: {:method => "get", :uri => "/assessments/{id}"}
		}
	end
end
