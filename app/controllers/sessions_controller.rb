class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: "Too many attempts. Try again in a few minutes." }

  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)

    if user
      reset_session
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = "Wrong email or password."
      render :new, status: 422
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: "Logged out."
  end
end
