json.extract! billing, :id, :patient_id, :statement_number, :statement_date, :period_start, :period_end, :subtotal_cents, :discount_cents, :total_cents, :status, :notes, :metadata, :created_at, :updated_at
json.url billing_url(billing, format: :json)
