Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :moves, ENV['MOVES_KEY'], ENV['MOVES_SECRET']
end
