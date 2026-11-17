require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  PACIFIC = "Pacific Time (US & Canada)".freeze

  setup do
    @existing = appointments(:ana_morning)
  end

  def build(starts_at:, practitioner: practitioners(:ana), duration: 30)
    Appointment.new(
      practitioner: practitioner,
      patient: patients(:priya),
      starts_at: starts_at,
      duration_minutes: duration
    )
  end

  def same_day_at(hour, min = 0)
    @existing.starts_at.in_time_zone(PACIFIC).change(hour: hour, min: min)
  end

  test "sets ends_at from the duration" do
    appointment = build(starts_at: same_day_at(13), duration: 45)
    appointment.valid?

    assert_equal appointment.starts_at + 45.minutes, appointment.ends_at
  end

  test "can't overlap another appointment with the same practitioner" do
    appointment = build(starts_at: @existing.starts_at + 15.minutes)

    assert_not appointment.valid?
    assert_includes appointment.errors[:base].join, "already booked"
  end

  test "can't start before and run into an existing appointment" do
    appointment = build(starts_at: @existing.starts_at - 15.minutes)

    assert_not appointment.valid?
  end

  test "back-to-back appointments are fine" do
    assert build(starts_at: @existing.ends_at).valid?
    assert build(starts_at: @existing.starts_at - 30.minutes).valid?
  end

  test "a different practitioner can take the same slot" do
    appointment = build(starts_at: @existing.starts_at, practitioner: practitioners(:ben))

    assert appointment.valid?
  end

  test "the database rejects an overlap even if validation is skipped" do
    appointment = build(starts_at: @existing.starts_at)
    # Skipping validation also skips before_validation, so set this by hand.
    appointment.ends_at = appointment.starts_at + 30.minutes

    assert_no_difference "Appointment.count" do
      assert_not appointment.save(validate: false)
    end
    assert_includes appointment.errors[:base].join, "already booked"
  end

  test "can't be booked in the past" do
    appointment = build(starts_at: 1.hour.ago)

    assert_not appointment.valid?
    assert_includes appointment.errors[:starts_at], "can't be in the past"
  end

  test "only allows set lengths" do
    appointment = build(starts_at: same_day_at(13), duration: 20)

    assert_not appointment.valid?
  end

  test "has to start inside working hours" do
    appointment = build(starts_at: same_day_at(8))

    assert_not appointment.valid?
    assert_match "working hours", appointment.errors[:starts_at].join
  end

  test "can't run past the end of the day" do
    appointment = build(starts_at: same_day_at(16, 45))

    assert_not appointment.valid?
  end

  test "can't be booked on a weekend unless the practitioner works weekends" do
    saturday = Date.current.next_occurring(:saturday).in_time_zone(PACIFIC).change(hour: 10)

    assert_not build(starts_at: saturday).valid?

    practitioners(:ana).update!(works_weekends: true)
    assert build(starts_at: saturday).valid?
  end

  test "working hours are checked in the practitioner's own time zone" do
    toronto = Practitioner.create!(name: "Dr. Toronto", time_zone: "Eastern Time (US & Canada)")

    # 7am Pacific is 10am in Toronto, inside a 9–5 day there.
    assert build(starts_at: same_day_at(7), practitioner: toronto).valid?
    # 3pm Pacific is 6pm in Toronto, after they've gone home.
    assert_not build(starts_at: same_day_at(15), practitioner: toronto).valid?
  end

  test "editing notes doesn't re-check the time" do
    @existing.notes = "Bring knee brace"

    assert @existing.valid?
  end

  test "booking schedules a reminder" do
    assert_enqueued_jobs 1, only: AppointmentReminderJob do
      build(starts_at: same_day_at(13)).save!
    end
  end
end
