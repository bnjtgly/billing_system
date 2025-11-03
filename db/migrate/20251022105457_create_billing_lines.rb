class CreateBillingLines < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_lines do |t|
      t.references :billing, null: false, foreign_key: true
      t.references :charge_checklist, null: false, foreign_key: true
      t.references :charge_checklist_item, null: false, foreign_key: true
      t.references :medicine, null: true, foreign_key: true
      t.date :date
      t.string :category
      t.string :item_code
      t.string :name
      t.string :route
      t.string :frequency
      t.string :dosage
      t.string :unit
      t.integer :quantity, null: false, default: 0
      t.integer :unit_price_cents, null: false, default: 0
      t.integer :amount_cents, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
    add_index :billing_lines, [:billing_id, :date]
    add_index :billing_lines, :item_code
    add_index :billing_lines, [:billing_id, :charge_checklist_item_id], unique: true, name: "idx_unique_billing_line_per_cc_item"
  end
end
