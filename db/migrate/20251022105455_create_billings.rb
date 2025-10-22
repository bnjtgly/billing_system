class CreateBillings < ActiveRecord::Migration[8.1]
  def change
    create_table :billings do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :statement_number, null: false
      t.date :statement_date
      t.date :period_start
      t.date :period_end
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :discount_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :status, null: false, default: "draft"
      t.text :notes
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
    add_index :billings, :statement_number, unique: true
    add_index :billings, [:patient_id, :statement_date]
  end
end
