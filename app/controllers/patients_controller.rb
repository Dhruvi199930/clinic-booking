class PatientsController < ApplicationController
  def index
    @patients = Patient.order(:name)
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)

    if @patient.save
      redirect_to patients_path, notice: "Added #{@patient.name}."
    else
      render :new, status: 422
    end
  end

  private

  def patient_params
    params.expect(patient: [ :name, :email ])
  end
end
