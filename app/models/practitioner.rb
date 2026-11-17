class Practitioner < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_error

  validates :name, presence: true

  def to_s
    name
  end
end
