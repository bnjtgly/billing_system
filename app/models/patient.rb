class Patient < ApplicationRecord
  has_many :charge_checklists, dependent: :restrict_with_error, inverse_of: :patient
  has_many :billings, dependent: :restrict_with_error, inverse_of: :patient

  def complete_name
    [first_name, last_name].compact.join(" ")
  end
end
