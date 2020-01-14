class OutgoingsPayloadGenerator
  def initialize(rows)
    @rows = rows
    # @payload_type = payload_type
    @payload = [] # array of multiple @source_hash
    @current_outgoing_type = nil # name of the current source
    # @source_hash = {} # the hash containing source and payments array
    @payments_array = [] # an array of @current_payment_hashes
    @payment_hash = {} # a hash of date and value
  end

  def run
    @rows.each do |row|
      change_outgoing_type(row) if new_outgoing_type?(row)

      change_date if new_date?(row)

      process_row(row)
    end
    save_current_outgoing_type
    { outgoings: @payload }
  end

  private

  def new_outgoing_type?(row)
    _object, outgoing_type, _attribute, _value = row
    outgoing_type.present?
  end

  def change_outgoing_type(row)
    _object, outgoing_type, _attribute, _value = row
    save_current_outgoing_type unless @current_outgoing_type.nil?
    @current_outgoing_type = outgoing_type
    @payments_array = []
    @payment_hash = {}
  end

  def new_date?(row)
    _object, _outgoing_type, attribute, _value = row
    attribute == 'payment_date'
  end

  def change_date
    # _object, _outgoing_type, _attribute, value = row
    @payments_array << @payment_hash unless @payment_hash.empty?
    @payment_hash = {}
  end

  def process_row(row)
    _object, _outgoing_type, attribute, value = row
    @payment_hash[attribute.to_sym] = value
  end

  def save_current_outgoing_type
    @payments_array << @payment_hash
    @payload << { name: @current_outgoing_type, payments: @payments_array }
  end
end
