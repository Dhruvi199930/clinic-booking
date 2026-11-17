class AppointmentReminderJob < ApplicationJob
  queue_as :default

  # Takes an id instead of the record so a cancelled (deleted) appointment
  # just gets skipped instead of failing to deserialize.
  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    return if appointment.nil? || appointment.starts_at.past?

    ReminderMailer.with(appointment: appointment).appointment_reminder.deliver_now
  end
end
