# returns true if all the attributes in expected hash have the same values in actual_model.
# Does not care if there are extra attributees in the model which are not in the hash
#
RSpec::Matchers.define :have_matching_attributes do | expected_hash |
  match do |actual_model|
    actual_hash = actual_model.attributes.symbolize_keys
    actual_hash.keep_if{ |key, vallue| expected_hash.key?(key) }
    actual_hash == expected_hash
  end

  failure_message do |actual_model|
    actual_hash = actual_model.attributes.symbolize_keys
    actual_hash.keep_if{ |key, vallue| expected_hash.key?(key) }
    "Not all specified attributes match:\n#{actual_hash.inspect}\n#{expected_hash.inspect}"
  end
end

RSpec::Matchers.define :have_zero_values do |*attributes|
  match do |actual_record|
    attributes.each do |attr|
      return false unless actual_record.__send__(attr).zero?
    end
  end

  failure_message do |actual_record|
    "Not all the specified attribtues are zero:\nAttributes examined: #{attributes.join(',')}\nRecord: #{actual_record.inspect}"
  end
end
