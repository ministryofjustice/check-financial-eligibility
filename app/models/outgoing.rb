# frozen_string_literal: true

class Outgoing < ApplicationRecord
  belongs_to :assessment

  enum outgoing_type: {
    rent: 'rent',
    mortgage: 'mortgage',
    child_care: 'child_care',
    maintenance: 'maintenance',
    legal_aid: 'legal_aid'
  }
end
