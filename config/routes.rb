Rails.application.routes.draw do
  devise_for :users

  resources :quotes, only: [:index, :new, :create, :show, :edit, :update] do
    member do
      post :generate_from_ai
    end
    resources :ai_messages, only: [:new, :create]
  end

  root to: "pages#home"
end

