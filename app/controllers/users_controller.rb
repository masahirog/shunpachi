class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = company_scope(User.all)
  end

  def show
  end

  private

  def set_user
    @user = company_scope(User).find(params[:id])
  end
end
