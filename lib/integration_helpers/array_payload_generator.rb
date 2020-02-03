class ArrayPayloadGenerator
  def initialize(rows, object_name, num_attrs)
    @chunks = rows.each_slice(num_attrs).to_a
    @object_name = object_name
  end

  def run
    array = []
    @chunks.each do |rows|
      hash = {}
      rows.each do |row|
        _object, _sub_object, attr, value = row
        hash[attr] = value
      end
      array << hash
    end
    { @object_name => array }
  end
end
