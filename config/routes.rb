Rails.application.routes.draw do
  resources :status, only: [:index]

  namespace 'api' do
    resources :statuses, only: [:index]
  end
end
