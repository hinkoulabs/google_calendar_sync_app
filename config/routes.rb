require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root 'home#index'

  # OmniAuth Google OAuth2 routes
  get '/auth/:provider/callback', to: 'sessions#create'   # This handles the callback from Google after authentication
  get '/auth/failure', to: redirect('/')                  # Redirect to home on failure
  delete '/logout', to: 'sessions#destroy'

  resources :calendars, only: [:index] do
    collection do
      post :sync
    end
  end

  mount Sidekiq::Web => '/sidekiq' # This will allow you to visit localhost:3000/sidekiq to monitor jobs
end
