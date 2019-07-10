module EnumHash
  # Pass in a list of enum elements and convert them to a hash
  # with the name.to_sym as key, and name.to_s as value
  def enum_hash_for(*names)
    names.flatten!
    names.map { |x| [x.to_sym, x.to_s] }.to_h
  end
end
