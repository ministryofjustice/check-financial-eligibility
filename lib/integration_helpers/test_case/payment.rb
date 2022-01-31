module TestCase
  class Payment
    def initialize(date:, client_id:, amount:, meta: nil)
      @date = date
      @client_id = client_id
      @amount = amount
      @meta = meta
    end

    def all_nil?
      [@data, @client_id, @amount, @meta].uniq == [nil]
    end

    def payload(date_field: :date)
      {
        "#{date_field}": @date.strftime("%F"),
        amount: @amount,
        client_id: @client_id
      }
    end
  end
end
