require "test_helper"

class ReminderMailerTest < ActionMailer::TestCase
  test "appointment reminder" do
    mail = ReminderMailer.with(appointment: appointments(:ana_morning)).appointment_reminder

    assert_equal [ "sam@example.com" ], mail.to
    assert_match "Reminder", mail.subject
    assert_match "Dr. Ana Reyes", mail.body.encoded
    assert_match "10:00 AM", mail.body.encoded
  end
end
