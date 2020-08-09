Rails.application.routes.draw do
  post 'users', to: 'users#create'
  delete 'users/:id', to: 'users#destroy'

  post 'courses', to: 'courses#create'
  delete 'courses/:id', to: 'courses#destroy'
  get 'courses', to: 'courses#index'
end
