Rails.application.routes.draw do
  apipie
  resources :assessments, only: %i[create show] do
    resource :applicant, only: [:create]
    resources :capitals, only: [:create]
    resources :dependants, only: [:create]
    resources :outgoings, only: [:create]
    resources :properties, only: [:create]
    resources :vehicles, only: :create
    resources :other_incomes, only: [:create]
    resources :state_benefits, only: [:create]
  end
  get 'ping', to: 'status#ping', format: :json
  get 'healthcheck', to: 'status#status', format: :json
  get 'status', to: 'status#ping', format: :json
end
