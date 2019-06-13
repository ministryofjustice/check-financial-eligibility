Rails.application.routes.draw do
  resources :assessments, only: [:create] do
    resources :dependents, only: [:create]
    resources :properties, only: [:create]
  end
end
