class Appointment < ApplicationRecord
  LENGTHS = [ 15, 30, 45, 60 ].freeze

  belongs_to :practitioner
  belongs_to :patient

  before_validation :set_ends_at

  validates :starts_at, presence: true
  validates :duration_minutes, inclusion: { in: LENGTHS }
  validate :starts_in_future, on: :create
  validate :practitioner_is_free

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }

  private

  # ends_at is stored so the overlap check is one plain SQL comparison
  # instead of date math that differs between databases.
  def set_ends_at
    return if starts_at.blank? || duration_minutes.blank?

    self.ends_at = starts_at + duration_minutes.minutes
  end

  def starts_in_future
    return if starts_at.blank?

    errors.add(:starts_at, "can't be in the past") if starts_at < Time.current
  end

  def practitioner_is_free
    return if practitioner.nil? || starts_at.blank? || ends_at.blank?

    clash = Appointment
      .where(practitioner_id: practitioner_id)
      .where.not(id: id)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
      .exists?

    errors.add(:base, "#{practitioner.name} is already booked at that time") if clash
  end
end
