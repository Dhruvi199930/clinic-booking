class AccountsController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(account_params)
      redirect_to root_path, notice: "Saved."
    else
      render :edit, status: 422
    end
  end

  private

  def account_params
    params.expect(user: [ :name, :time_zone ])
  end
end
