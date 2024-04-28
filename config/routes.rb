require "sidekiq/web"

Rails.application.routes.draw do
  get "search/index"
  post "search", to: "search#index"
  get "search_history", to: "home#search_history"
  get "/privacy", to: "home#privacy"
  get "/terms", to: "home#terms"
  get "product_graph/:id", to: "home#product_graph", as: :product_graph
  get "product_details/:product_id/:gl", to: "home#product_details", as: :product_details
  get "comparisons/:product_id", to: "comparisons#show", as: "show_comparison"  
  get "comparisons/:product_id/comparison", to: "comparisons#comparison", as: "detailed_comparison"
  get "product_details/:product_id/:gl/forecast", to: "home#forecast", as: "product_forecast"
  post 'predictions/create', to: 'predictions#create'


authenticate :user, lambda { |u| u.admin? } do
  mount Sidekiq::Web => "/sidekiq"

  namespace :madmin do
    resources :impersonates do
      post :impersonate, on: :member
      post :stop_impersonating, on: :collection
    end
  end
end

  resources :notifications, only: [:index]
  resources :announcements, only: [:index]
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  root to: "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
