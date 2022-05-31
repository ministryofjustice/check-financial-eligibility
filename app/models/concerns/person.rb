module Person
    def age_at_submission
        return unless submission_date

        ((submission_date.to_time - date_of_birth.to_time) / 1.year).to_i
    end
end