class Billing < ApplicationRecord
  belongs_to :patient
  has_many :billing_lines, dependent: :destroy
  has_many :billing_checklists, dependent: :destroy
  has_many :charge_checklists, through: :billing_checklists

  validates :statement_number, presence: true, uniqueness: { case_sensitive: false }
  validates :subtotal_cents, :discount_cents, :total_cents, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :billing_lines, allow_destroy: true

  enum :status, { draft: "draft", issued: "issued", void: "void" }

  def recalc_totals!
    update!(
      subtotal_cents: billing_lines.sum(:amount_cents),
      total_cents: billing_lines.sum(:amount_cents) - discount_cents.to_i
    )
  end

  # Build denormalized lines from selected checklists (stable for printing)
  # app/models/billing.rb
  def populate_from_checklists!(checklists)
    medicine_map = Medicine.where(id: extract_medicine_ids(checklists)).index_by(&:id)

    checklists.each do |cc|
      billing_checklists.find_or_create_by!(charge_checklist_id: cc.id)
      cc.line_items.includes(:charge_item).each do |li|
        ci = li.charge_item
        med_id = li.metadata.is_a?(Hash) ? li.metadata["medicine_id"] : nil
        med = medicine_map[med_id]
        unit_cents = li.unit_price_cents.presence || ci.default_price_cents.to_i
        qty = li.quantity.to_i

        billing_lines.build(
          charge_checklist: cc,
          charge_checklist_item: li,
          medicine_id: med&.id,
          date: cc.performed_on,
          category: ci.charge_category&.name,
          item_code: med&.item_code,
          name: med ? med.drug_name : ci.name,
          route: med&.route,
          frequency: med&.frequency,
          dosage: med&.dosage.presence || med&.strength,
          unit: ci.unit || med&.unit,
          quantity: qty,
          unit_price_cents: unit_cents,
          amount_cents: unit_cents * qty,
          metadata: {}
        )
      end
    end

    save!
    recalc_totals!
  end

  private

  def extract_medicine_ids(checklists)
    checklists.flat_map { |cc| cc.line_items.filter_map { |li| li.metadata.is_a?(Hash) ? li.metadata["medicine_id"] : nil } }.uniq
  end
end