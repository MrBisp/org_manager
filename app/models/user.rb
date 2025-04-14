class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  belongs_to :organization, optional: true
  enum :role, { member: 0, admin: 1 }
  
end
