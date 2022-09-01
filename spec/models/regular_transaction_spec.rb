RSpec.describe RegularTransaction, type: :model do
  it { is_expected.to belong_to(:gross_income_summary) }
end
