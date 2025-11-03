class CreateChargeChecklistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :charge_checklist_items do |t|
      t.references :charge_checklist, null: false, foreign_key: true
      t.references :charge_item, null: false, foreign_key: true
      t.references :medicine, null: true, foreign_key: true
      t.integer :quantity
      t.integer :unit_price_cents
      t.integer :total_cents
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :charge_checklist_items, [:charge_checklist_id, :charge_item_id]
  end
end
