Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "posts#index"
  resources :posts, only: [:index, :show]

  # Defines the root path route ("/")
  # root "posts#index"
end
