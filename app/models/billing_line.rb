class BillingLine < ApplicationRecord
  belongs_to :billing
  belongs_to :charge_checklist
  belongs_to :charge_checklist_item
  belongs_to :medicine, optional: true

  validates :quantity, :unit_price_cents, :amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
