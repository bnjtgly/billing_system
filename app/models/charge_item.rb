class ChargeItem < ApplicationRecord
  belongs_to :charge_category
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
end
