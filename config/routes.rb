Serendipities::Application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: 'logout'
  get '/mapdata', to: 'mapdata#show', as: 'mapdata'
  root to: 'homepage#show'
end
