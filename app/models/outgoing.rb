class Outgoing < ApplicationRecord
  extend EnumHash
  belongs_to :assessment

  enum outgoing_type: enum_hash_for(:rent, :mortgage, :child_care, :maintenance, :legal_aid)
end
