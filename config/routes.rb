Rails.application.routes.draw do
  # RESTful resource routes
  resources :transfers, only: [ :create, :index ]
  resources :transactions, only: [ :create, :index ]
  resources :accounts
  resources :users, only: [ :create, :show ]

  # Authentication routes
  post "login" => "authentication#create", as: :login
  post "register" => "users#create", as: :register

  # Accounts routes
  get "my_balance" => "accounts#my_balance", as: :my_balance

  # Tranfers routes
  post "/transfer" => "transfers#create"

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
