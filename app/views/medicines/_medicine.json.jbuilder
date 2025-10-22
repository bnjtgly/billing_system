json.extract! medicine, :id, :item_code, :drug_name, :generic_name, :frequency, :dosage, :route, :unit, :unit_price_cents, :qty, :notes, :metadata, :active, :created_at, :updated_at
json.url medicine_url(medicine, format: :json)
