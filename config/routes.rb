Rails.application.routes.draw do
  namespace 'api' do
    resources :statuses, only: [:index]
  end
end
