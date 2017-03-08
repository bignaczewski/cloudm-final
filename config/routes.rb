Rails.application.routes.draw do

  devise_for :users
  root 'visitors#index'

end
