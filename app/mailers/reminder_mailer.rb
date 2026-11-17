class ReminderMailer < ApplicationMailer
  def appointment_reminder
    @appointment = params[:appointment]
    @patient = @appointment.patient
    @starts_at = @appointment.starts_at.in_time_zone(@appointment.practitioner.time_zone)

    mail to: @patient.email,
         subject: "Reminder: your appointment on #{@starts_at.strftime('%A, %B %-d')}"
  end
end
