class User < ApplicationRecord
  has_secure_password
  belongs_to :role
  has_many :charge_checklists
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def complete_name
    "#{first_name} #{last_name}".squish
  end
end
