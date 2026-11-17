class ApplicationController < ActionController::Base
  before_action :require_login
  around_action :use_staff_time_zone

  helper_method :current_user

  private

  def current_user
    return if session[:user_id].blank?

    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to new_session_path, alert: "Please log in." unless current_user
  end

  # Times are stored in UTC. Each staff member sees them in their own zone.
  def use_staff_time_zone(&)
    Time.use_zone(current_user&.time_zone || Time.zone, &)
  end
end
