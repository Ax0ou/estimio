Rails.application.routes.draw do
  devise_for :users

  # Routes des devis
  resources :quotes, only: [:index, :new, :create, :show, :edit, :update]

  # Page d'accueil en racine
  root to: "pages#home"
end
