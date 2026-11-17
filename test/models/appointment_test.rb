require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
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

  test "sets ends_at from the duration" do
    appointment = build(starts_at: @existing.ends_at + 1.hour, duration: 45)
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

  test "can't be booked in the past" do
    appointment = build(starts_at: 1.hour.ago)

    assert_not appointment.valid?
    assert_includes appointment.errors[:starts_at], "can't be in the past"
  end

  test "only allows set lengths" do
    appointment = build(starts_at: @existing.ends_at + 1.hour, duration: 20)

    assert_not appointment.valid?
  end

  test "editing an appointment doesn't clash with itself" do
    @existing.notes = "Bring knee brace"

    assert @existing.valid?
  end
end
