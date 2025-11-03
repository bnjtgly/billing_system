class ChargeChecklistItem < ApplicationRecord
  belongs_to :charge_checklist
  belongs_to :charge_item
  belongs_to :medicine, optional: true
  before_validation do
    if unit_price_cents.blank?
      self.unit_price_cents = medicine&.unit_price_cents.presence || charge_item&.default_price_cents || 0
    end
  end
  before_save { self.total_cents = (unit_price_cents.to_i * quantity.to_i) }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  # Presenters for consistent downstream use
  def display_item_code
    medicine&.item_code
  end

  def display_name
    medicine ? medicine.drug_name : charge_item&.name
  end

  def display_route
    medicine&.route
  end

  def display_frequency
    medicine&.frequency
  end

  def display_dosage
    medicine&.dosage.presence || medicine&.strength
  end

  def display_unit
    medicine&.unit || charge_item&.unit
  end
end
