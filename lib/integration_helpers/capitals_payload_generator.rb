class CapitalsPayloadGenerator
  def initialize(rows)
    @rows = rows
    @payload = {}
    @current_category_name = nil
    @category_array = []
    @item_hash = {}
  end

  def run
    @rows.each do |row|
      change_category(row) if new_category?(row)

      change_item(row) if description?(row)

      store_value(row) if value?(row)
    end
    store_previous_category
    @payload.symbolize_keys
  end

  private

  def new_category?(row)
    _object, category, _attr, _value = row
    category.present? && category != @current_category_name
  end

  def change_category(row)
    store_previous_category unless @current_category_name.nil?
    initialize_category(row)
  end

  def description?(row)
    _object, _category, attr, _value = row
    attr == 'description'
  end

  def change_item(row)
    store_previous_item unless @item_hash.empty?
    initialize_item(row)
  end

  def value?(row)
    _object, _category, attr, _value = row
    attr == 'value'
  end

  def initialize_category(row)
    _object, category, _attr, _value = row
    @current_category_name = category
    @category_array = []
    @item_hash = {}
  end

  def initialize_item(row)
    _object, _category, _attr, value = row
    @item_hash = { description: value }
  end

  def store_previous_category
    store_previous_item
    @payload[@current_category_name] = @category_array
    @category_array = []
  end

  def store_value(row)
    _object, _category, _attr, value = row
    @item_hash[:value] = value
  end

  def store_previous_item
    @category_array << @item_hash
  end
end
