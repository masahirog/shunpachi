class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @company = current_company
  end

  def update
    @user = current_user
    @company = current_company
    
    success_messages = []

    # 企業情報の更新
    if company_params.present? && company_params[:name].present?
      if @company.update(company_params)
        success_messages << '企業情報を更新しました。'
      else
        render :show, status: :unprocessable_entity and return
      end
    end

    # ユーザー情報の更新
    if user_params.present? && (user_params[:name].present? || user_params[:email].present? || user_params[:password].present?)
      # パスワードが空の場合は更新対象から除外
      cleaned_params = user_params.dup
      if cleaned_params[:password].blank?
        cleaned_params.delete(:password)
        cleaned_params.delete(:password_confirmation)
      end

      if @user.update(cleaned_params)
        success_messages << 'アカウント情報を更新しました。'
      else
        render :show, status: :unprocessable_entity and return
      end
    end

    message = success_messages.any? ? success_messages.join(' ') : 'アカウント情報を更新しました。'
    redirect_to profile_path, notice: message
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:name, :email, :password, :password_confirmation)
  end

  def company_params
    params.fetch(:company, {}).permit(:name)
  end
end