Rails.application.routes.draw do

  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  # root 'application#hello'
  root 'static_pages#home'

  # get 'static_pages/help'
  get '/help', to: 'static_pages#help' #=> help_path
  # get 'static_pages/about'
  get '/about', to: 'static_pages#about' #=> about_path
  # get 'static_pages/contact'
  get '/contact', to: 'static_pages#contact' #=> contact_path


  get '/signup', to: 'users#new'
  # post '/signup', to: 'users#create'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users

  # アカウント有効化(editアクションを追加)
  resources :account_activations, only: [:edit]
  # パスワード再設定用リソースのルーティング
  resources :password_resets, only: [:new, :create, :edit, :update]
  # マイクロポストのリソースのルーティング
  resources :microposts, only: [:create, :destroy]


end
