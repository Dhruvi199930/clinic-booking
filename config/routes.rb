Rails.application.routes.draw do
  root "appointments#index"

  resources :appointments, only: %i[index new create destroy]
  resources :practitioners, except: :destroy
  resources :patients, only: %i[index new create]

  resource :session, only: %i[new create destroy]
  resource :account, only: %i[edit update]

  get "up" => "rails/health#show", as: :rails_health_check
end
