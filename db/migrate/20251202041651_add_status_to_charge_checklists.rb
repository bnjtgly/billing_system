class AddStatusToChargeChecklists < ActiveRecord::Migration[8.1]
  def change
    add_column :charge_checklists, :status, :string, default: "unbilled", null: false
  end
end
