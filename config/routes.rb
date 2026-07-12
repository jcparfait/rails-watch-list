Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  root to: "lists#index"

  get "movie-night", to: "movie_nights#new", as: :movie_night
  post "movie-night", to: "movie_nights#create"
  post "movie-night/save", to: "movie_nights#save", as: :save_movie_night

  resources :lists do
    get "movies/search", to: "movie_searches#index", as: :movie_search
    post "movies/import", to: "movie_imports#create", as: :movie_import
    resources :bookmarks, only: [ :new, :create ]
  end

  resources :movies, only: [] do
    resources :movie_reviews, only: [ :create ]
  end

  resources :bookmarks, only: [ :edit, :update, :destroy ]
  resources :movie_reviews, only: [ :destroy ]
end
