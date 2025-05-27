Rails.application.routes.draw do
  devise_for :users

  # Routes des devis
  resources :quotes, only: [:index, :new, :create, :show, :edit, :update] do
    resources :ai_messages, only: [:new, :create]
  end

  # Page d'accueil en racine
  root to: "pages#home"
end
