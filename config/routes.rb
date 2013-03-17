Workspace::Application.routes.draw do

  # ADMIN
  #
  #
  namespace :admin do
    resources :age_group_types, :except => [:show] do
      resources :age_group_entries, :only => [:index, :create]
    end
    resources :age_group_entries, :except => [:index, :create]

    resources :registrants, :only => [:index, :show] do
      collection do
        get :bag_labels
        get :club
      end
      member do
        post :undelete
      end
    end
    resources :payments, :only => [:index]
    resources :events, :only => [:index, :show]

    namespace :export do
      get :index
      get :download_data
      get :download_configuration
      post :upload
      get :download_events
    end

    resources :users, :only => [:index] do
      member do
        put :admin
        put :club_admin
      end
    end
    resources :history, :only => [:index] 

    resources :standard_skill_entries, :only => [] do
      collection do
        get :upload_file
        post :upload
      end
    end
    resources :standard_skill_routines, :only => [] do
      collection do
        get :download_file
      end
    end
  end
  resources :expense_groups

  resources :expense_items, :except => [:new, :show]

  resources :payments do
    collection do
      post 'notification'
      get 'success'
    end

    member do
      post 'fake_complete'
    end
  end

  resources :registration_periods

  resources :event_choices, :except => [:index, :create, :new]

  resources :events, :except => [:index, :new, :show, :create] do
    resources :event_choices, :only => [:index, :create]
  end

  resources :categories, :except => [:new, :show] do
    resources :events, :only => [:index, :create]
  end

  resources :registrants do
    collection do
      get :new_noncompetitor
      get :all
    end
    member do
      get :items
      put :update_items
      get :waiver
    end
    resources :registrant_expenses, :only => [:new, :destroy]
    resources :standard_skill_routines, :only => [:index, :create]
  end

  resources :standard_skill_routines, :only => [:show] do
    resources :standard_skill_routine_entries, :only => [:destroy, :create]
  end
  resources :standard_skill_entries, :only => [:index]

  # for AJAX use:
  resources :registrant_expenses, :only => [] do
    collection do
      post 'single'
    end
  end

  resources :event_configurations do
    collection do
      post 'admin'
      post 'super_admin'
      post 'club_admin'
      post 'normal'
    end
    member do
      get 'logo'
    end
  end

  get "welcome/help"
  post "welcome/feedback"
  get "welcome/confirm"

  devise_for :users, :controllers => { :registrations => "registrations" }

  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

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
  root :to => 'registrants#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
