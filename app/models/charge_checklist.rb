class ChargeChecklist < ApplicationRecord
  belongs_to :patient
  belongs_to :user
  has_many :line_items, class_name: "ChargeChecklistItem", dependent: :destroy
  has_many :billing_checklists, dependent: :destroy
  has_many :billings, through: :billing_checklists
  accepts_nested_attributes_for :line_items, reject_if: ->(a){ a["quantity"].to_i <= 0 }

  after_save :mark_as_issued

  def mark_as_issued
    update_column(:issued, "Issued") if issued.blank?
  end

  def billed?
    status == "billed"
  end

  def unbilled?
    status == "unbilled"
  end
end
