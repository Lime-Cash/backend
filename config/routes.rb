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
  get "balance" => "accounts#balance", as: :balance
  get "activity" => "accounts#activity", as: :activity

  # Tranfers routes
  post "/transfer" => "transfers#create"

  # Transactions routes
  post "/deposit_bank" => "transactions#deposit_bank", as: :deposit_bank
  post "/withdraw_bank" => "transactions#withdraw_bank", as: :withdraw_bank

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
