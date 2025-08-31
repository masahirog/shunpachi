class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_current_company

  # # Devise のヘルパーメソッドを有効化
  # include Devise::Controllers::Helpers
  # helper_method :user_signed_in?, :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  def set_current_company
    @current_company = current_user&.company
    redirect_to root_path, alert: 'アクセス権限がありません。' if current_user && !@current_company
  end

  def company_scope(relation)
    return relation unless @current_company
    relation.where(company: @current_company)
  end

  helper_method :current_company

  def current_company
    @current_company
  end
end
