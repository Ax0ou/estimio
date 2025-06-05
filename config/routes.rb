Rails.application.routes.draw do
  devise_for :users


  resources :companies, only: [] do
    resources :clients, only: [:index, :new, :create]
    resources :quotes, only: [:index, :new, :create]
  end

  resources :clients, only: [:show, :edit, :update, :destroy]
  resources :quotes, only: [:show, :edit, :update, :destroy] do
    member do
      post :add_section
    end
    resources :sections, only: [:new, :create, :index]
  end

  resources :sections, only: [:show, :edit, :update, :destroy] do
    member do
      post :add_line_items_with_llm
      post :transcribe_audio
    end
    resources :line_items, only: [:new, :create]
    resources :ai_messages, only: [:new, :create]
  end

  resources :line_items, only: [:edit, :update, :destroy]

  # Page d'accueil en racine
  root to: "pages#home"
end

# /restautants/fdsfsdfdfdsf
