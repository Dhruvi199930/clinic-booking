class PractitionersController < ApplicationController
  before_action :set_practitioner, only: %i[show edit update]

  def index
    @practitioners = Practitioner.order(:name)
  end

  def show
    @appointments = @practitioner.appointments.upcoming.includes(:patient)
  end

  def new
    @practitioner = Practitioner.new
  end

  def create
    @practitioner = Practitioner.new(practitioner_params)

    if @practitioner.save
      redirect_to @practitioner, notice: "Added #{@practitioner.name}."
    else
      render :new, status: 422
    end
  end

  def edit
  end

  def update
    if @practitioner.update(practitioner_params)
      redirect_to @practitioner, notice: "Saved."
    else
      render :edit, status: 422
    end
  end

  private

  def set_practitioner
    @practitioner = Practitioner.find(params[:id])
  end

  def practitioner_params
    params.expect(practitioner: [ :name, :specialty, :day_starts_at_hour, :day_ends_at_hour, :works_weekends, :time_zone ])
  end
end
