Rails.application.routes.draw do
  post 'users', to: 'users#create'
  delete 'users/:id', to: 'users#destroy'

  post 'courses', to: 'courses#create'
  delete 'courses/:id', to: 'courses#destroy'
  get 'courses', to: 'courses#index'

  post 'courses/:course_id/enrollments', to: 'enrollments#create'
  delete 'courses/:course_id/enrollments/:user_id', to: 'enrollments#destroy'
end
