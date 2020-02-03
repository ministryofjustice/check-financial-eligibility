# returns a hash, where each key is the name of an object (assessment, applicant, defencants, etc)
# and the values are an array of rows which will be used to create that object
#
class EndpointDataExtractor
  attr_reader :objects

  def initialize(worksheet_rows)
    @rows = worksheet_rows
    @endpoint_datasets = {}
  end

  def run
    current_object = nil
    @rows.each do |row|
      break if row.first == 'Expected results'

      if row.first.present?
        @endpoint_datasets[row.first] = [row]
        current_object = row.first
      else
        @endpoint_datasets[current_object] << row
      end
    end
    @endpoint_datasets
  end
end
