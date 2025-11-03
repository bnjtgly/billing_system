class Billing < ApplicationRecord
  belongs_to :patient
  has_many :billing_lines, dependent: :destroy
  has_many :billing_checklists, dependent: :destroy
  has_many :charge_checklists, through: :billing_checklists

  validates :statement_number, presence: true, uniqueness: { case_sensitive: false }
  validates :subtotal_cents, :discount_cents, :total_cents, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :billing_lines, allow_destroy: true

  enum :status, { draft: "draft", issued: "issued" }

  def recalc_totals!
    update!(
      subtotal_cents: billing_lines.sum(:amount_cents),
      total_cents: billing_lines.sum(:amount_cents) - discount_cents.to_i
    )
  end

  # Build denormalized lines from selected checklists (stable for printing)
  # app/models/billing.rb
  def populate_from_checklists!(checklists)
    Billings::GenerateFromChecklists.call(billing: self, checklists: Array(checklists))
  end

  private

  def extract_medicine_ids(checklists)
    checklists
      .flat_map do |cc|
        cc.line_items.filter_map do |li|
          next unless li.metadata.is_a?(Hash)
          li.metadata["medicine_id"] || li.metadata[:medicine_id]
        end
      end
      .map { |id| id.to_i }
      .reject { |id| id <= 0 }
      .uniq
  end
end