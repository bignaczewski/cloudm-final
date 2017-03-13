Rails.application.routes.draw do

  get 'app_settings', to: 'app_settings#index'
  post 'create_db', to: 'app_settings#create_db'
  post 'delete_db', to: 'app_settings#delete_db'
  post 'connect_db', to: 'app_settings#connect_db'
  post 'connect_db_local', to: 'app_settings#connect_db_local'

  resources :posts, except: :show

  devise_for :users

  root 'posts#index'

end
