class ChargeChecklist < ApplicationRecord
  belongs_to :patient
  has_many :line_items, class_name: "ChargeChecklistItem", dependent: :destroy
  accepts_nested_attributes_for :line_items, reject_if: ->(a){ a["quantity"].to_i <= 0 }
end
