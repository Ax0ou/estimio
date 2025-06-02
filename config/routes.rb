Rails.application.routes.draw do
  devise_for :users

  resources :companies, only: [:new, :create, :show, :edit, :update, :destroy] do
    resources :clients, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :quotes, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
      resources :sections, only: [:new, :create, :edit, :update, :destroy] do
        resources :ai_messages, only: [:new, :create]
        resources :line_items, only: [:new, :create, :edit, :update, :destroy]
      end
    end
  end

  # Page d'accueil en racine
  root to: "pages#home"
end
