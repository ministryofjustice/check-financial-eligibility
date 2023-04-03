module TestCase
  class Payment
    def initialize(date:, client_id:, amount:, housing_cost_type: nil)
      @date = date
      @client_id = client_id
      @amount = amount
      @housing_cost_type = housing_cost_type
    end

    def all_nil?
      [@data, @client_id, @amount, @housing_cost_type].uniq == [nil]
    end

    def payload(date_field: :date)
      {
        "#{date_field}": @date.strftime("%F"),
        amount: @amount,
        client_id: @client_id,
      }.tap do |p|
        p[:housing_cost_type] = @housing_cost_type if @housing_cost_type.present?
      end
    end
  end
end
