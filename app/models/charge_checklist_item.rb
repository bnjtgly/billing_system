class ChargeChecklistItem < ApplicationRecord
  belongs_to :charge_checklist
  belongs_to :charge_item
  before_validation { self.unit_price_cents ||= charge_item&.default_price_cents || 0 }
  before_save { self.total_cents = (unit_price_cents.to_i * quantity.to_i) }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
