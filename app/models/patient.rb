class Patient < ApplicationRecord
  has_many :charge_checklists, dependent: :restrict_with_error, inverse_of: :patient
end
