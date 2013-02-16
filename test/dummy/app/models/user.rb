class User < ActiveRecord::Base
  attr_accessible :name

  has_secure_password

  validates :name,
    length:     { maximum: 42, minimum: 3 },
    presence:   true,
    uniqueness: { case_sensitive: false },
    format:     { with: /^[[:word:]\.'` ]+$/i }
end
