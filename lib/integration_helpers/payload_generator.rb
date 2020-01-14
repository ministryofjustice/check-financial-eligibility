class PayloadGenerator
  def initialize(rows, top_level_name = nil)
    @rows = rows
    @top_level_name = top_level_name
  end

  def run
    payload = {}
    @rows.each do |row|
      _object, _sub_object, attribute, value = row
      payload[attribute] = value.is_a?(Date) ? value.strftime('%Y-%m-%d') : value
    end
    @top_level_name.nil? ? payload : { @top_level_name => payload }
  end
end
