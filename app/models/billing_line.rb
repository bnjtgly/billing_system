class BillingLine < ApplicationRecord
  belongs_to :billing
  belongs_to :charge_checklist
  belongs_to :charge_checklist_item
  belongs_to :medicine, optional: true

  validates :quantity, :unit_price_cents, :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  # Helpers to distinguish and access underlying catalog items without extra FKs
  def medicine?
    medicine_id.present?
  end

  def charge_item
    charge_checklist_item&.charge_item
  end

  def charge_item_id
    charge_item&.id
  end

  def line_kind
    medicine? ? "medicine" : "catalog"
  end
end
