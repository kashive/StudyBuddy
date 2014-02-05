StudyBuddy::Application.routes.draw do

  get "static_pages/bugs"
  get "static_pages/how"
  get "static_pages/team"
  get "static_pages/idea"

  resources :get_in_touches, :only=>[:new, :create]

  # devise_for :users do
  #   get "/", :to => "sessions#new"
  # end

  match'/users',to:'application#destroyUser', via: :delete

  devise_for :users, :controllers => {  :omniauth_callbacks=> "omniauth_callbacks",
                                        :sessions => "sessions",
                                        :registrations => "registrations"
                                       }

  devise_scope :user do get "/" => "devise/sessions#new" end

  resources :users  do
    resources :notifications, :only => [:index]
    resources :schedules, :only=>[:new, :create, :show]
    resources :study_sessions, :only => [:index]
    resources :courses, :only => [:index,:create,:show,:new,:destroy] do
      resources :study_sessions
    end
  end

  root :to => "devise/sessions#new"
  
  get '/users/:id/dashboard', to:"dashboards#show" ,as: "dashboard"
  put '/notification_seen', to: "notifications#seen"
  put '/update_schedule', to: "schedules#update_schedule"
  post '/checkUserExist', to: "users#checkUserExist"
  post '/users/:user_id/courses/:course_id/study_sessions/:id/invitations_update/:status', to: "study_sessions#updateInvitation", as: "invitation_update"
  resources :activities
 
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
