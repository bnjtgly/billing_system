class BillingChecklist < ApplicationRecord
  belongs_to :billing
  belongs_to :charge_checklist

  validates :charge_checklist_id, uniqueness: { scope: :billing_id }
end
