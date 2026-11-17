class PractitionersController < ApplicationController
  def index
    @practitioners = Practitioner.order(:name)
  end

  def show
    @practitioner = Practitioner.find(params[:id])
    @appointments = @practitioner.appointments.upcoming.includes(:patient)
  end
end
