class ChargeCategory < ApplicationRecord
  has_many :charge_items, -> { order(:position, :name) }, dependent: :restrict_with_error
  validates :name, :key, presence: true
end
