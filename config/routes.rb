Rails.application.routes.draw do

  mount RailsSettingsUi::Engine, at: 'settings'

  resources :posts, except: :show

  devise_for :users

  root 'posts#index'

end
