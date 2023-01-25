# BigDecimals get encoded as strings rather than numbers
# https://discuss.rubyonrails.org/t/bigdecimal-encoded-as-string-in-json/74396
# https://github.com/rails/rails/issues/25017
class BigDecimal
  def as_json(*)
    to_f
  end
end
