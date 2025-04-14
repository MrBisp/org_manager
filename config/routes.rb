Rails.application.routes.draw do
  # This defines the routes for organization users so that they can be found at /organizations/:organization_id/users/:id
  resources :organizations do
    resources :users do
      get :assign, on: :collection
      post :update_assignment, on: :collection
    end
  end

  # Defines a resource for session (singular!). We use this for the login form (see app/controllers/sessions_controller.js).
  resource :session

  # Defines a resource for passwords . We use this for the forgot password form (see app/controllers/passwords_controller.js).
  resources :passwords, param: :token

  # Defines a resource for registrations (singular!). We use this for the signup form (see app/controllers/registrations_controller.js).
  resources :registrations, only: %i[new create], path: "signup"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "organizations#index"
end
