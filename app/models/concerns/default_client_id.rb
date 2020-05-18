module DefaultClientId
  def client_id
    attributes['client_id'] || "#{self.class}:#{payment_date.strftime('%F')}:#{amount}"
  end
end
