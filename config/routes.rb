Rails.application.routes.draw do

  resources :posts, except: :show
  get 'settings/index'

  devise_for :users
  root 'posts#index'

end
