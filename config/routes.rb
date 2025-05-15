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
  get "accounts/balance/:account_id/" => "accounts#balance", as: :balance

  # Tranfers routes
  post "/transfers" => "transfers#create"

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
