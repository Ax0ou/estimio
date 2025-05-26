Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Page d'accueil en racine
  root to: "users#home"

  # Page d'accueil accessible aussi par /home
  get "/home", to: "users#home"

  # Formulaire d'inscription
  get "/user/new", to: "users#new"
  post "/user", to: "users#create"

  # Routes des devis
  scope :user do
    resources :quotes, only: [:index, :new, :create, :show, :edit, :update]
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
