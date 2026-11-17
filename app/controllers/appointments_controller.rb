class AppointmentsController < ApplicationController
  def index
    appointments = Appointment.upcoming.includes(:practitioner, :patient)
    @days = appointments.group_by { |a| a.starts_at.to_date }
  end

  def new
    @appointment = Appointment.new(
      practitioner_id: params[:practitioner_id],
      starts_at: Time.zone.tomorrow.in_time_zone.change(hour: 9)
    )
  end

  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      redirect_to appointments_path,
        notice: "Booked #{@appointment.patient.name} with #{@appointment.practitioner.name}."
    else
      render :new, status: 422
    end
  end

  def destroy
    Appointment.find(params[:id]).destroy
    redirect_to appointments_path, notice: "Appointment cancelled."
  end

  private

  def appointment_params
    params.expect(appointment: [ :practitioner_id, :patient_id, :starts_at, :duration_minutes, :notes ])
  end
end
