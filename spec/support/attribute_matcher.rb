RSpec::Matchers.define :have_matching_attributes do |expected_hash, attribute_list|
  match do |actual_hash|
    attribute_list.each do |meth|
      return false unless actual_hash.__send__(meth) == expected_hash.__send__(meth)
    end
  end

  failure_message do |actual_hash|
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
