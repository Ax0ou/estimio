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
      get :download_pdf
      patch :update_legal_mentions
    end
    resources :sections, only: [:new, :create, :index]
  end

  resources :sections, only: [:show, :edit, :update, :destroy] do
    member do
      post :add_line_items_with_llm
      post :transcribe_audio
      post :analyze_with_ai  # Nouvelle route pour l'analyse IA
      get :totals           # Nouvelle route pour récupérer les totaux
    end
    resources :line_items, only: [:new, :create]
    resources :ai_messages, only: [:new, :create]
  end

  # Routes pour les nouvelles fonctionnalités IA/Audio
  namespace :ai do
    post :transcribe      # Transcription audio
    post :analyze_text    # Analyse de texte par IA
  end

  # Routes pour les données en temps réel
  resources :quotes, only: [:show, :edit, :update, :destroy] do
    member do
      post :add_section
      get :download_pdf
      patch :update_legal_mentions
      get :totals           # Récupérer les totaux du devis
      get :section_totals   # Récupérer les totaux par section
      get :sections         # Liste des sections pour le select
    end
    resources :sections, only: [:new, :create, :index]
  end

  resources :line_items, only: [:edit, :update, :destroy]

  resources :products do
    post :import, on: :collection
  end

  post "/line_items/reorder", to: "line_items#reorder", as: :reorder_line_items

  # Page d'accueil en racine
  root to: "pages#home"
end

# /restautants/fdsfsdfdfdsf
