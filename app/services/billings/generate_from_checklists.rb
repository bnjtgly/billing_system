module Billings
  class GenerateFromChecklists
    def self.call(billing:, checklists:)
      new(billing, Array(checklists)).call
    end

    def initialize(billing, checklists)
      @billing = billing
      @checklists = checklists
    end

    def call
      # Link selected checklists for traceability
      @checklists.each do |cc|
        @billing.billing_checklists.find_or_create_by!(charge_checklist_id: cc.id)
      end

      # Rebuild lines idempotently (clear then build)
      @billing.billing_lines.destroy_all

      preload_line_items = @checklists.flat_map do |cc|
        cc.line_items.includes(:charge_item, :medicine)
      end

      preload_line_items.each do |li|
        ci = li.charge_item
        med = li.medicine

        unit_cents = if li.unit_price_cents.present?
                       li.unit_price_cents
                     else
                       (med&.unit_price_cents.presence || ci&.default_price_cents.to_i)
                     end
        qty = li.quantity.to_i

        @billing.billing_lines.build(
          charge_checklist: li.charge_checklist,
          charge_checklist_item: li,
          medicine_id: med&.id,
          date: li.charge_checklist.performed_on,
          category: ci&.charge_category&.name,
          item_code: li.respond_to?(:display_item_code) ? li.display_item_code : med&.item_code,
          name: li.respond_to?(:display_name) ? li.display_name : (med ? med.drug_name : ci&.name),
          route: li.respond_to?(:display_route) ? li.display_route : med&.route,
          frequency: li.respond_to?(:display_frequency) ? li.display_frequency : med&.frequency,
          dosage: li.respond_to?(:display_dosage) ? li.display_dosage : (med&.dosage.presence || med&.strength),
          unit: li.respond_to?(:display_unit) ? li.display_unit : (med&.unit || ci&.unit),
          quantity: qty,
          unit_price_cents: unit_cents,
          amount_cents: unit_cents.to_i * qty,
          metadata: {}
        )
      end

      @billing.save!
      @billing.recalc_totals!
    end
  end
end


