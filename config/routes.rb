Rails.application.routes.draw do
  # RESTful resource routes
  resources :transfers, only: [ :create, :index ]
  resources :transactions, only: [ :create, :index ]
  resources :accounts
  resources :users, only: [ :create, :show ]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
