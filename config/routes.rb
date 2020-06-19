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
    resource :irregular_income, only: [:create]
    resources :state_benefits, only: [:create]
  end
  resources :state_benefit_type, only: [:index]

  get 'ping', to: 'status#ping', format: :json
  get 'healthcheck', to: 'status#status', format: :json
  get 'status', to: 'status#ping', format: :json
  get 'state_benefit_type', to: 'state_benefit_type#index', format: :json
end
