module AuthenticationHelper

  def sign_in user
    credentials = user.oauth_credentials[0]
    OmniAuth.config.mock_auth[:moves] = OmniAuth::AuthHash.new({
      provider: 'moves',
      uid: credentials.uid,
      token: credentials.token,
      refresh_token: credentials.refresh_token,
      expires_at: credentials.expires_at
      # etc.
    })
    # request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:moves]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:moves]

    request.session[:user_id] = user.id
  end

  def sign_out
    request.env["omniauth.auth"] = nil
  end

end
