Rails.application.routes.draw do
  apipie
  resources :assessments, only: %i[create show] do
    resource :applicant, only: [:create]
    resources :capitals, only: [:create]
    resources :dependants, only: [:create]
    resource :income, only: [:create]
    resources :outgoings, only: [:create]
    resources :properties, only: [:create]
    resources :vehicles, only: :create
  end
  resources :status, only: [:index]
end
