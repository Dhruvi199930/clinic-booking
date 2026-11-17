require "test_helper"

class PractitionerTest < ActiveSupport::TestCase
  test "the day has to end after it starts" do
    practitioner = Practitioner.new(name: "Backwards", day_starts_at_hour: 17, day_ends_at_hour: 9)

    assert_not practitioner.valid?
    assert_includes practitioner.errors[:day_ends_at_hour], "must be after the start of the day"
  end

  test "rejects a made-up time zone" do
    practitioner = Practitioner.new(name: "Nowhere", time_zone: "Mars/Olympus")

    assert_not practitioner.valid?
  end

  test "hours label" do
    assert_equal "9am–5pm Mon–Fri, Pacific Time (US & Canada)", practitioners(:ana).hours_label
  end
end
