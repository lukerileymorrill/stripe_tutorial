Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "posts#index"
  resources :posts, only: [:index, :show]

  # Defines the root path route ("/")
  # root "posts#index"
  get 'pricing', to: 'stripe/checkout#pricing'
  post 'stripe/checkout', to: 'stripe/checkout#checkout'
  get 'stripe/checkout/success', to: 'stripe/checkout#success'
  get 'stripe/checkout/cancel', to: 'stripe/checkout#cancel'
  post 'stripe/billing_portal', to: 'stripe/billing_portal#create'
  namespace :stripe do 
    post '/webhooks', to: 'webhooks#create'
  end
end
