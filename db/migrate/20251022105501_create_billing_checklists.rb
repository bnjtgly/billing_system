class CreateBillingChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_checklists do |t|
      t.references :billing, null: false, foreign_key: true
      t.references :charge_checklist, null: false, foreign_key: true

      t.timestamps
    end
    add_index :billing_checklists, [:billing_id, :charge_checklist_id], unique: true
  end
end
