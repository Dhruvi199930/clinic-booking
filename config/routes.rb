Rails.application.routes.draw do
  root "appointments#index"

  resources :appointments, only: %i[index new create destroy]
  resources :practitioners, only: %i[index show]
  resources :patients, only: %i[index new create]

  get "up" => "rails/health#show", as: :rails_health_check
end
