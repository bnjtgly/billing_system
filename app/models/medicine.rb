class Medicine < ApplicationRecord
  validates :item_code, presence: true, uniqueness: { case_sensitive: false }
  validates :drug_name, presence: true
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :search, ->(q) {
    return all if q.blank?
    where("LOWER(item_code) LIKE :q OR LOWER(drug_name) LIKE :q OR LOWER(generic_name) LIKE :q", q: "%#{q.downcase}%")
  }
end
