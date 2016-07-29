FactoryGirl.define do
  factory :oauth_credentials do
    uid "60429574245191498"
    token "uQxAdCWM0ioEeE_AP2vW5tcH_Hx45i9U0Vrpwx9Q_e8E9mF1Ju7..."
    refresh_token "0Fh8zhVz0Rm0om18m9Hmi597uSk_q8t_S03Wut33SCeC1IDreG0..."
    expires_at {Time.now + 1.year}
    user
  end
end
