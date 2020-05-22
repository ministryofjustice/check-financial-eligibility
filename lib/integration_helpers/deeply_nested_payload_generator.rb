# generalised payload generator to produce payloads for 2-tier payloads, like
# other_incomes, state_benefits, outgoings
class DeeplyNestedPayloadGenerator
  CUSTOMIZATION = {
    other_incomes: {
      top_level_name: :other_incomes,
      second_level_name: :source,
      second_level_collection: :payments,
      date_method: :date,
      amount_method: :amount,
      client_id_method: :client_id
    },
    state_benefits: {
      top_level_name: :state_benefits,
      second_level_name: :name,
      second_level_collection: :payments,
      date_method: :date,
      amount_method: :amount,
      client_id_method: :client_id
    },
    outgoings: {
      top_level_name: :outgoings,
      second_level_name: :name,
      second_level_collection: :payments,
      date_method: :payment_date,
      amount_method: :amount,
      client_id_method: :client_id
    }
  }.freeze

  def initialize(rows, payload_type)
    @rows = rows
    @payload_type = payload_type
    @payload = [] # array of multiple @source_hash
    @current_source = nil # name of the current source
    @source_hash = {} # the hash containing source and payments array
    @payments_array = [] # an array of @current_payment_hashes
    @payment_hash = {} # a hash of date and value
  end

  def run
    @rows.each do |row|
      change_source(row) if new_source?(row)

      change_date(row) if new_date?(row)

      store_amount(row) if amount?(row)

      client_id?(row) ? store_client_id(row) : create_client_id(row)
    end
    store_payment_source
    { top_level_name => @payload }
  end

  def change_source(row)
    store_payment_source unless @current_source.nil?
    initialize_payment_hash
    initialize_payment_source(row)
  end

  def change_date(row)
    store_payment_hash unless @payment_hash.empty?
    initialize_new_date(row)
  end

  def top_level_name
    CUSTOMIZATION[@payload_type][:top_level_name]
  end

  def second_level_name
    CUSTOMIZATION[@payload_type][:second_level_name]
  end

  def second_level_collection
    CUSTOMIZATION[@payload_type][:second_level_collection]
  end

  def date_method
    CUSTOMIZATION[@payload_type][:date_method]
  end

  def amount_method
    CUSTOMIZATION[@payload_type][:amount_method]
  end

  def client_id_method
    CUSTOMIZATION[@payload_type][:client_id_method]
  end

  def new_source?(row)
    _object, source, _attr, _value = row
    source.present? && source != @current_source
  end

  def new_date?(row)
    _object, _source, attr, _value = row
    attr == 'date'
  end

  def amount?(row)
    _object, _source, attr, _value = row
    attr == 'amount'
  end

  def client_id?(row)
    _object, _source, attr, _value = row
    attr == 'client_id'
  end

  def initialize_new_date(row)
    _object, _source, _attr, value = row
    @payment_hash = { date_method => value }
  end

  def initialize_payment_source(row)
    _object, source, _attr, _value = row
    @current_source = source
    @source_hash = { second_level_name => source, second_level_collection => [] }
  end

  def initialize_payments_array
    @payments_array = []
  end

  def initialize_payment_hash
    @payment_hash = {}
  end

  def store_payment_source
    store_payment_hash
    store_payments_array
    @payload << @source_hash
    initialize_payments_array
    initialize_payment_hash
  end

  def store_payments_array
    @source_hash[second_level_collection] = @payments_array
  end

  def store_payment_hash
    @payments_array << @payment_hash
  end

  def store_amount(row)
    _object, _source, _attr, value = row
    @payment_hash[amount_method] = value
  end

  def store_client_id(row)
    _object, _source, _attr, value = row
    @payment_hash[client_id_method] = value
  end

  # TODO: Remove #create_client_id method when integration tests spreadsheet passes in client_id with payments
  def create_client_id(_row)
    @payment_hash[client_id_method] = SecureRandom.uuid
  end
end
