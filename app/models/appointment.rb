class Appointment < ApplicationRecord
  LENGTHS = [ 15, 30, 45, 60 ].freeze
  REMINDER_LEAD_TIME = 24.hours

  belongs_to :practitioner
  belongs_to :patient

  before_validation :set_ends_at

  validates :starts_at, presence: true
  validates :duration_minutes, inclusion: { in: LENGTHS }
  validate :starts_in_future, on: :create
  validate :within_working_hours, if: :time_or_practitioner_changed?
  validate :practitioner_is_free

  after_create_commit :schedule_reminder

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }

  # The trigger in the database is the real guard against double-booking.
  # If two requests race past the validation, the second insert is rejected
  # there, and this turns that into a normal form error.
  def save(**)
    super
  rescue ActiveRecord::StatementInvalid => e
    raise unless e.message.include?("appointment_overlap")

    errors.add(:base, already_booked_message)
    false
  end

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

  def time_or_practitioner_changed?
    will_save_change_to_starts_at? || will_save_change_to_ends_at? || will_save_change_to_practitioner_id?
  end

  def within_working_hours
    return if practitioner.nil? || starts_at.blank? || ends_at.blank?
    return if practitioner.available_between?(starts_at, ends_at)

    errors.add(:starts_at, "is outside #{practitioner.name}'s working hours (#{practitioner.hours_label})")
  end

  def practitioner_is_free
    return if practitioner.nil? || starts_at.blank? || ends_at.blank?

    clash = Appointment
      .where(practitioner_id: practitioner_id)
      .where.not(id: id)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
      .exists?

    errors.add(:base, already_booked_message) if clash
  end

  def already_booked_message
    "#{practitioner.name} is already booked at that time"
  end

  def schedule_reminder
    send_at = [ starts_at - REMINDER_LEAD_TIME, Time.current ].max
    AppointmentReminderJob.set(wait_until: send_at).perform_later(id)
  end
end
