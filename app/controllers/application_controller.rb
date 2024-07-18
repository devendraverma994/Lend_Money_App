class ApplicationController < ActionController::Base
  before_action :set_wallet
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_wallet
    @wallet = current_user.wallet if user_signed_in?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
end
