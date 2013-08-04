Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :moves, ENV.fetch('MOVES_KEY'), ENV.fetch('MOVES_SECRET')
end
