Workspace::Application.routes.draw do
  require 'sidekiq/web'
  authenticate :user, ->(u) { u.has_role? :admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  scope "(:locale)" do
    resources :registrant_groups, :except => [:new] do
      collection do
        get :list
      end
      member do
        get :address_labels
      end
    end

    namespace :printing do
      namespace :race_recording do
        get :blank
        get :instructions
      end
      resources :competitions, :only => [] do
        member do
          get :announcer
          get :start_list
          get :heat_recording
          get :single_attempt_recording
          get :two_attempt_recording
          get :results
          get :sign_in_sheet
        end
      end
      resources :events, :only => [] do
        member do
          get :results
        end
      end
    end

    # ADMIN (for use in Setting up the system)
    #
    #
    resources :age_group_types, :except => [:new] do
      member do
        get :set_sort
        post :sort
      end
    end

    resources :permissions, :only => [:index] do
      collection do
        post :create_race_official
        get :directors
        put :set_role
        get :acl
        post :set_acl
        get :code
        post :use_code
      end
    end


    namespace :export do
      get :index
      get :download_payment_details
      get :download_all_payments
      get :download_events
      get :download_competitors_for_timers
      get :results
    end

    resources :standard_skill_entries, :only => [:index] do
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

    #### For Registration creation purposes
    ###

    resources :expense_groups

    resources :expense_items, :except => [:new, :show] do
      member do
        get :details
      end
    end

    resources :refunds, :only => [:show]

    resources :payments, :except => [:index, :edit, :update,:destroy] do
      collection do
        get :summary
        post :notification
        get :success
      end

      member do
        post :fake_complete
        post :complete
        post :apply_coupon
      end
    end
    resources :payment_adjustments, :only => [:new]  do
      collection do
        get :list
        post :adjust_payment_choose
        post :onsite_pay_confirm
        post :onsite_pay_create
        post :refund_choose
        post :refund_create
        post :exchange_choose
        post :exchange_create
      end
    end


    resources :registration_periods

    resources :combined_competitions do
      resources :combined_competition_entries, except: [:show]
    end
    resources :competition_wheel_sizes

    resources :coupon_codes
    resources :event_choices, :except => [:index, :create, :new]

    resources :events, :except => [:index, :new, :create] do
      resources :event_choices, :only => [:index, :create]
      resources :event_categories, :only => [:index, :create]
      collection do
        get 'summary'
      end
      member do
        post :create_director
        delete :destroy_director
        get :sign_ups
      end
      resources :competitions, :only => [:new, :create]
    end
    resources :event_categories, :except => [:index, :create, :new, :show] do
      member do
        get :sign_ups
      end
    end

    resources :categories, :except => [:new, :show] do
      resources :events, :only => [:index, :create]
    end

    # backwards-compatible URL
    get '/registrants/:id/items', to: redirect('/registrants/%{id}/registrant_expense_items')

    resources :emails, only: [:index, :create] do
      collection do
        get :list
      end
    end

    resources :registrants, except: [:index] do
      resources :build, controller: 'registrants/build', only: [:show, :update, :create]
      #admin
      collection do
        get :bag_labels
        get :show_all
        get :manage_all
        get :manage_one
        post :choose_one
      end
      member do
        post :undelete
        get :reg_fee
        put :update_reg_fee
        get :results
      end

      #normal user
      collection do
        get :all
        get :empty_waiver
      end
      member do
        get :waiver
      end
      resources :registrant_expense_items, :only => [:index, :create, :destroy]
      resources :standard_skill_routines, :only => [:index, :create]
      member do
        get :payments, to: "payments#registrant_payments"
      end
      resources :payments, :only => [:index]
      resources :songs, :only => [:index, :create]
      resources :competition_wheel_sizes, only: [:index, :create]
    end
    resources :competition_wheel_sizes, only: :destroy

    resources :songs, :only => [:destroy] do
      collection do
        get :list
      end
      member do
        get :add_file
        get :file_complete
      end
    end

    resources :standard_skill_routines, :only => [:show, :index] do
      resources :standard_skill_routine_entries, :only => [:destroy, :create]
    end
    resources :standard_skill_entries, :only => [:index]

    # for AJAX use:
    resources :registrant_expenses, :only => [] do
      collection do
        post 'single'
      end
    end

    resources :event_configurations, :except => [:show] do
      collection do
        post :test_mode_role
      end
      member do
        get 'logo'
      end
    end

    get "usa_memberships", to: "usa_memberships#index"
    put "usa_memberships", to: "usa_memberships#update"
    get "usa_memberships/export", to: "usa_memberships#export"
    get "volunteers", to: "volunteers#index"
    resources :volunteer_opportunities

    get "results", to: "results#index"
    get "welcome/help"
    post "welcome/feedback"
    get "welcome/confirm"
    get 'welcome/data_entry_menu'

    devise_for :users, :controllers => { :registrations => "registrations" }

    resources :users, :only => [] do
      resources :registrants, :only => [:index]
      resources :payments, :only => [:index]
      resources :additional_registrant_accesses, :only => [:index, :new, :create] do
        collection do
          get :invitations
        end
      end
      resources :competition, :only => [] do
        #resources :single_attempt_entries, only: [:index, :create]
        resources :two_attempt_entries, only: [:index, :create] do
          collection do
            get :proof
            post :approve
          end
        end

        resources :import_results, :only => [:create] do
          collection do
            get :proof_single

            # These 2 don't use @user, move them?
            get :review
            post :approve

            get :review_heat
            post :approve_heat
            delete :delete_heat

            get  :data_entry
            get :import_csv, as: "display_csv", to: :display_csv
            post :import_csv
            get :import_chip, as: "display_chip", to: :display_chip
            post :import_chip
            get :import_lif, as: "display_lif", to: :display_lif
            post :import_lif
            delete :destroy_all
          end
        end
      end
      resources :award_labels, :shallow => true, :except => [:new, :show] do
        collection do
          post :create_by_competition
          post :create_labels
          get :expert_labels
          get :normal_labels
          delete :destroy_all
          get :announcer_sheet
        end
      end
      resources :songs, :only => [] do
        collection do
          get :my_songs
          post :create_guest_song
        end
      end
    end
    resources :additional_registrant_accesses, :only => [] do
      member do
        put :accept_readonly
        delete :decline
      end
    end
    resources :import_results, :only => [:edit, :update, :destroy]
    resources :two_attempt_entries, :only => [:edit, :update, :destroy]
    resources :competition_results, only: [:destroy]

    ###############################################
    ### For event-data-gathering/reporting purposes
    ###############################################

    resources :competitors, :only => [:edit, :update, :destroy]

    resources :competitions, :only => [:show, :edit, :update, :destroy] do
      member do
        get :set_sort
        post :sort
        put :toggle_final_sort
        post :sort_random
        post :set_age_group_places
        post :set_places
        get :export_scores
        # view scores
        get :result

        post :lock
        delete :lock, to: 'competitions#unlock'
        post :publish
        delete :publish, to: 'competitions#unpublish'
        post :publish_age_group_entry
        post :award
        delete :award
      end
      resources :competition_results, only: [:create]
      resources :competitors, :only => [:index, :new, :create] do
        collection do
          post :add
          post :add_all
          delete :destroy_all
          get :enter_sign_in
          put :update_competitors
          get :display_candidates
          post :create_from_candidates
        end
      end

      resources :heats, :only => [:index, :new, :create] do
        collection do
          # Track (LaneAssignments)
          delete :destroy_all

          # 10k (Competitor->Heat)
          get :upload_form
          post :upload
          get "age_group_entries/:age_group_entry_id/set_sort", to: "heats#set_sort", as: "set_sort"
          post "age_group_entries/:age_group_entry_id/set_sort", to: "heats#sort", as: "sort"
        end
      end

      resources :data_entry_volunteers, :only => [:index, :create]

      resources :judges,      :only => [:index, :create, :destroy] do
        collection do
          post :copy_judges
        end
      end
      resources :time_results, :only => [:index, :create]
      resources :lane_assignments, :only => [:index, :create] do
        collection do
          get :view_heat
          post :dq_competitor
          get :review
          get :download_heats_evt
        end
      end
      resources :distance_attempts, only: [] do
        collection do
          get :list
        end
      end
      resources :external_results, :shallow => true, :except => [:new, :show]
      resources :published_age_group_entries, only: [:show] do
        member do
         get :preview
        end
      end
    end
    resources :lane_assignments, :except => [:new, :index, :create, :show]

    resources :time_results, :except => [:index, :new, :show, :create]

    resources :judges, :only => [:update] do
      resources :competitors, :only => [] do
        resources :scores, :only => [:new, :create]

        # display chosen competitors current scores, and update them
        resources :standard_scores, :only => [:new, :create]
      end

      #choose the desired competitor to add scores to
      resources :scores, :only => [:index]
      resources :standard_scores, :only => [:index]
      resources :distance_attempts, :only => [:index, :create]
      resources :tie_break_adjustments, only: [:index, :create]
      resources :street_scores, :only => [:index, :destroy] do
        collection do
          post :update_score
        end
      end
    end
    resources :distance_attempts, :only => [:update, :destroy]
    resources :tie_break_adjustments, only: [:destroy]

  end

  resources :styles, only: :index

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
  get '/:locale' => 'welcome#index' # to match /en  to send to /en/welcome
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
