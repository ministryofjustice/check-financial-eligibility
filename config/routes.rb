Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  resources :assessments, only: %i[create show] do
    resource :applicant, only: [:create]
    resources :capitals, only: [:create]
    resources :dependants, only: [:create]
    resources :outgoings, only: [:create]
    resources :properties, only: [:create]
    resources :vehicles, only: :create
    resources :other_incomes, only: [:create]
    resource :irregular_incomes, only: [:create]
    resources :state_benefits, only: [:create]
    resources :explicit_remarks, only: [:create]
    resources :cash_transactions, only: [:create]
    resources :employments, only: [:create]
    resources :proceeding_types, only: [:create]
  end
  resources :state_benefit_type, only: [:index]

  get "ping", to: "status#ping", format: :json
  get "healthcheck", to: "status#status", format: :json
  get "status", to: "status#ping", format: :json
  get "state_benefit_type", to: "state_benefit_type#index", format: :json
end
