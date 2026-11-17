require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  test "lists upcoming appointments" do
    get appointments_path

    assert_response :success
    assert_select "td", text: "Sam Lee"
  end

  test "books an appointment" do
    starts_at = appointments(:ana_morning).ends_at + 2.hours

    assert_difference "Appointment.count", 1 do
      post appointments_path, params: { appointment: {
        practitioner_id: practitioners(:ana).id,
        patient_id: patients(:priya).id,
        starts_at: starts_at,
        duration_minutes: 30
      } }
    end

    assert_redirected_to appointments_path
  end

  test "shows an error instead of double-booking" do
    assert_no_difference "Appointment.count" do
      post appointments_path, params: { appointment: {
        practitioner_id: practitioners(:ana).id,
        patient_id: patients(:priya).id,
        starts_at: appointments(:ana_morning).starts_at,
        duration_minutes: 30
      } }
    end

    assert_response 422
    assert_select ".errors", /already booked/
  end

  test "cancels an appointment" do
    assert_difference "Appointment.count", -1 do
      delete appointment_path(appointments(:ana_morning))
    end
  end
end
