Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  root to: "lists#index"

  resources :lists do
    resources :bookmarks, only: [ :new, :create ]
    resources :reviews, only: [ :create ]
  end

  resources :bookmarks, only: [ :edit, :update, :destroy ]
  resources :reviews, only: [ :edit, :update, :destroy ]
end
