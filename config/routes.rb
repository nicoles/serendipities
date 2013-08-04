Serendipities::Application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
end
