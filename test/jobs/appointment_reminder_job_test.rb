require "test_helper"

class AppointmentReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends the reminder" do
    assert_emails 1 do
      AppointmentReminderJob.perform_now(appointments(:ana_morning).id)
    end
  end

  test "does nothing if the appointment was cancelled" do
    appointment = appointments(:ana_morning)
    appointment.destroy

    assert_emails 0 do
      AppointmentReminderJob.perform_now(appointment.id)
    end
  end
end
