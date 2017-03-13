Rails.application.routes.draw do

  get 'app_settings', to: 'app_settings#index'
  post 'create_db', to: 'app_settings#create_db'
  post 'delete_db', to: 'app_settings#delete_db'
  post 'connect_db', to: 'app_settings#connect_db'
  post 'connect_db_local', to: 'app_settings#connect_db_local'
  post 'create_app_and_env', to: 'app_settings#create_app_and_env'
  post 'terminate_env', to: 'app_settings#terminate_env'
  post 'terminate_app', to: 'app_settings#terminate_app'
  post 'prepare_data_migration', to: 'app_settings#prepare_data_migration'
  post 'invoke_data_migration', to: 'app_settings#invoke_data_migration'
  post 'create_superuser', to: 'app_settings#create_superuser'

  resources :posts, except: :show

  devise_for :users

  root 'posts#index'

end
