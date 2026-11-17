require "test_helper"

class PatientTest < ActiveSupport::TestCase
  test "email is cleaned up before saving" do
    patient = Patient.create!(name: "Tom Becker", email: "  Tom@Example.COM ")

    assert_equal "tom@example.com", patient.email
  end

  test "email has to be unique, ignoring case" do
    patient = Patient.new(name: "Another Sam", email: "SAM@example.com")

    assert_not patient.valid?
  end
end
