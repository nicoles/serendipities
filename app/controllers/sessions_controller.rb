class SessionsController < ApplicationController
  skip_before_filter :ensure_authenticated!

  def create
    self.current_user = User.find_or_create_from_auth_hash(auth_hash)
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
