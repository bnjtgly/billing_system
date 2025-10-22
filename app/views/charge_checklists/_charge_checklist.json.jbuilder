json.extract! charge_checklist, :id, :patient_id, :performed_on, :notes, :metadata, :created_at, :updated_at
json.url charge_checklist_url(charge_checklist, format: :json)
