Rails.application.routes.draw do
  devise_for :users

  root to: 'loans#index'

  namespace :admin do
    resources :users, only: [:index, :show, :edit, :update, :destroy]
  end

  resources :users, only: [:index, :show]

  get 'loans/index'

  resources :loans, only: [:new, :index, :create, :show] do
    member do
      patch :approve
      put :open
      put :close
      patch :reject
      patch :accept
      patch :repay
      get :set_interest_rate
    end
  end
end
