Rails.application.routes.draw do
  get 'transcriptions/create'
  devise_for :users

  # Routes des devis
  resources :quotes, only: [:index, :new, :create, :show, :edit, :update] do
    resources :ai_messages, only: [:new, :create]
  end

  post '/transcriptions', to: 'transcriptions#create'

  # Page d'accueil en racine
  root to: "pages#home"
end
