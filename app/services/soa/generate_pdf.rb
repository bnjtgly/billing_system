require "prawn"
require "prawn/table"
require "active_support"
require "active_support/number_helper"

module Soa
  class GeneratePdf
    # Public entrypoint
    # Usage:
    #   Soa::GeneratePdf.call(patient: patient, checklists: patient.charge_checklists)
    # Returns a PDF binary String.
    def self.call(patient:, checklists: nil)
      new(patient: patient, checklists: checklists).call
    end

    def initialize(patient:, checklists: nil)
      @patient = patient
      @checklists_relation =
        if checklists.nil?
          default_checklists
        elsif checklists.respond_to?(:includes)
          # ActiveRecord::Relation or AssociationRelation
          checklists
        else
          # Array of records or ids → normalize to relation for safe eager loading
          ids = Array(checklists).map { |c| c.respond_to?(:id) ? c.id : c }
          ChargeChecklist.where(id: ids)
        end
    end

    def call
      # Eager load to avoid N+1 and ensure stable rendering
      relation = @checklists_relation
                   .includes(line_items: [:medicine, :charge_item])
                   .order(performed_on: :asc, created_at: :asc)

      rows = build_table_rows(relation)
      total_cents = rows.sum { |r| r[:amount_cents] }

      build_pdf(rows: rows, total_cents: total_cents)
    end

    private

    def default_checklists
      @patient
        .charge_checklists
        .includes(:line_items)
        .order(performed_on: :asc, created_at: :asc)
    end

    def build_table_rows(checklists)
      rows = []
      checklists.each do |cc|
        cc.line_items.each do |li|
          date = cc.performed_on || cc.created_at&.to_date
          category = li.charge_item&.charge_category&.name
          item_name = if li.respond_to?(:display_name)
                        li.display_name
                      else
                        li.medicine ? li.medicine&.drug_name : li.charge_item&.name
                      end
          unit = if li.respond_to?(:display_unit)
                   li.display_unit
                 else
                   li.medicine&.unit || li.charge_item&.unit
                 end

          unit_price_cents = li.unit_price_cents.to_i
          amount_cents = li.total_cents.to_i.nonzero? || (unit_price_cents * li.quantity.to_i)

          rows << {
            date: date,
            category: category.to_s,
            item: item_name.to_s,
            quantity: li.quantity.to_i,
            unit: unit.to_s,
            unit_price_cents: unit_price_cents,
            amount_cents: amount_cents
          }
        end
      end
      rows
    end

    def build_pdf(rows:, total_cents:)
      pdf = Prawn::Document.new(page_size: "A4", margin: 36) # 0.5 inch margins

      # Header
      pdf.text "Statement of Account", size: 18, style: :bold, align: :center
      pdf.move_down 8
      pdf.text @patient.complete_name.to_s, size: 12, style: :bold, align: :center
      pdf.move_down 4
      pdf.text patient_secondary_line, size: 10, align: :center
      pdf.move_down 16

      # Table
      table_data = []
      table_data << ["Date", "Category", "Item", "Qty", "Unit", "Unit Price", "Total"]
      rows.each do |r|
        table_data << [
          (r[:date].presence || "").to_s,
          truncate(r[:category], 28),
          truncate(r[:item], 42),
          r[:quantity].to_s,
          truncate(r[:unit], 10),
          format_currency(r[:unit_price_cents]),
          format_currency(r[:amount_cents])
        ]
      end

      pdf.table(
        table_data,
        header: true,
        row_colors: ["F9F9F9", "FFFFFF"],
        cell_style: { size: 9, padding: [4, 6, 4, 6] },
        width: pdf.bounds.width
      ) do |t|
        t.row(0).font_style = :bold
        t.row(0).background_color = "EEEEEE"
        t.columns(3..3).align = :right
        t.columns(5..6).align = :right
      end

      pdf.move_down 10

      # Totals
      pdf.stroke_horizontal_rule
      pdf.move_down 6
      pdf.text "Total: #{format_currency(total_cents)}", size: 11, style: :bold, align: :right

      pdf.render
    end

    def format_currency(cents)
      amount = (cents.to_i / 100.0)
      ActiveSupport::NumberHelper.number_to_currency(amount, unit: "PHP", precision: 2)
    end

    def truncate(text, length)
      str = text.to_s
      return str if str.length <= length
      str[0, length - 1] + "…"
    end

    def patient_secondary_line
      parts = []
      if @patient.respond_to?(:date_of_birth) && @patient.date_of_birth.present?
        parts << "DOB: #{@patient.date_of_birth}"
      end
      parts << @patient.address.to_s if @patient.respond_to?(:address) && @patient.address.present?
      parts.compact_blank.join("  •  ")
    end
  end
end


