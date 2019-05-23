Rails.application.routes.draw do
  resources :assessments, only: [:create]
end
