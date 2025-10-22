json.extract! charge_item, :id, :name, :charge_category_id, :unit, :default_price_cents, :position, :active, :metadata, :inventory_item_id, :created_at, :updated_at
json.url charge_item_url(charge_item, format: :json)
