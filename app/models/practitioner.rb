class Practitioner < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_error

  validates :name, presence: true
  validates :day_starts_at_hour, numericality: { only_integer: true, in: 0..23 }
  validates :day_ends_at_hour, numericality: { only_integer: true, in: 1..24 }
  validates :time_zone, inclusion: { in: ->(_) { ActiveSupport::TimeZone.all.map(&:name) } }
  validate :day_ends_after_it_starts

  # Hours are in the practitioner's own time zone, so a 9am start means 9am
  # where they work, whatever zone the person booking is in.
  def available_between?(starts_at, ends_at)
    local_start = starts_at.in_time_zone(time_zone)
    local_end = ends_at.in_time_zone(time_zone)
    return false if local_start.on_weekend? && !works_weekends

    day = local_start.beginning_of_day
    local_start >= day + day_starts_at_hour.hours && local_end <= day + day_ends_at_hour.hours
  end

  def hours_label
    days = works_weekends ? "every day" : "Mon–Fri"
    "#{format_hour(day_starts_at_hour)}–#{format_hour(day_ends_at_hour)} #{days}, #{time_zone}"
  end

  def to_s
    name
  end

  private

  def day_ends_after_it_starts
    return if day_starts_at_hour.blank? || day_ends_at_hour.blank?

    errors.add(:day_ends_at_hour, "must be after the start of the day") if day_ends_at_hour <= day_starts_at_hour
  end

  def format_hour(hour)
    return "midnight" if hour == 24 || hour.zero?

    suffix = hour < 12 ? "am" : "pm"
    "#{hour > 12 ? hour - 12 : hour}#{suffix}"
  end
end
