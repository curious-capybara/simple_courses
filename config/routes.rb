Rails.application.routes.draw do
  post 'users', to: 'users#create'
  delete 'users/:id', to: 'users#destroy'
end
