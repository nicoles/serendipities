module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    before_filter :ensure_authenticated!
    helper_method :current_user
  end

  private

  def current_user
    return unless session[:user_id].present?
    @current_user ||= User.find(session[:user_id])
  end


  def current_user=(user)
    @current_user = user
    session[:user_id] = user.id
  end

  def authenticated?
    !session[:user_id].nil?
  end

  def admin?
    authenticated? && current_user.admin?
  end

  def require_user_be_admin!
    unauthorized! unless admin?
  end

  def ensure_authenticated!
    return if authenticated?
    redirect_to '/auth/moves'
  end
end
