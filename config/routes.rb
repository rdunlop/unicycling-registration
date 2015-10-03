Workspace::Application.routes.draw do
  mount Tolk::Engine => '/tolk', :as => 'tolk'
  require 'sidekiq/web'
  authenticate :user, ->(u) { u.has_role?(:super_admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '404', to: 'errors#not_found'
  get '415', to: 'errors#not_found'
  get '422', to: 'errors#not_permitted'
  get '500', to: 'errors#internal_server_error'

  scope "(:locale)" do
    resources :registrant_groups, except: [:new] do
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
      resources :competitions, only: [] do
        member do
          get :announcer
          get :start_list
          get :heat_recording
          get :single_attempt_recording
          get :two_attempt_recording
          get :results
        end
      end
      resources :events, only: [] do
        member do
          get :results
        end
      end
    end

    # ADMIN (for use in Setting up the system)
    #
    #
    resources :age_group_types, except: [:new], controller: "compete/age_group_types"
    resources :age_group_entries, only: [], controller: "compete/age_group_entries" do
      post :update_row_order, on: :collection
    end

    resources :permissions, only: [:index], controller: "admin/permissions" do
      collection do
        get :directors
        put :set_role
        put :set_password

        get :acl, controller: "permissions"
        post :set_acl, controller: "permissions"
        get :display_acl, controller: "admin/permissions"
        get :code, controller: "permissions"
        post :use_code, controller: "permissions"
      end
    end

    get '/translations', to: 'admin/translations#index'
    delete '/translations/cache', to: 'admin/translations#clear_cache'
    namespace :translations do
      resource :event_configuration, only: [:edit, :update]
      resources :categories, only: [:index, :edit, :update]
      resources :event_choices, only: [:index, :edit, :update]
      resources :expense_groups, only: [:index, :edit, :update]
      resources :expense_items, only: [:index, :edit, :update]
      resources :registration_periods, only: [:index, :edit, :update]
    end

    namespace :export do
      get :index
      get :download_payment_details
      get :download_all_payments, controller: "/export_registrants", action: "download_with_payment_details"
      get :download_all_registrants, controller: "/export_registrants", action: "download_all"
      get :download_events
      get :download_competitors_for_timers
      get :results
    end
    resource :import, only: [:new, :create]

    resources :standard_skill_entries, only: [:index] do
      collection do
        get :upload_file
        post :upload
      end
    end
    resources :standard_skill_routines, only: [] do
      collection do
        get :download_file
      end
    end

    #### For Registration creation purposes
    ###
    namespace "research" do
      resources :competitions, only: [:index] do
        collection do
          get :competitions
        end
      end
    end

    resources :expense_groups, except: [:show], controller: "convention_setup/expense_groups" do
      post :update_row_order, on: :collection
      resources :expense_items, except: [:new, :show], controller: "convention_setup/expense_items"
    end

    resources :expense_items, only: [], controller: "convention_setup/expense_items" do
      post :update_row_order, on: :collection
    end

    resources :expense_items, only: [] do
      member do
        get :details
      end
    end

    resources :refunds, only: [:show]

    resource :export_payments, only: [] do
      collection do
        get :list
        put :payments
        put :payment_details
      end
    end

    get  "/payments/set_reg_fees", controller: "admin/reg_fees", action: :index, as: "set_reg_fees"
    post "/payments/update_reg_fee", controller: "admin/reg_fees", action: :update_reg_fee, as: "update_reg_fee"

    resources :payments, except: [:index, :edit, :update, :destroy] do
      collection do
        get :summary
        post :notification, controller: "paypal_payments"
        get :success, controller: "paypal_payments"
        get :offline
      end

      member do
        post :fake_complete
        post :complete
        post :apply_coupon
      end
    end
    resources :manual_payments, only: [:new, :create], controller: "admin/manual_payments" do
      collection do
        get :choose
      end
    end
    resources :manual_refunds, only: [:new, :create], controller: "admin/manual_refunds" do
      collection do
        get :choose
      end
    end

    resources :payment_adjustments, only: [:new]  do
      collection do
        get :list
        post :adjust_payment_choose
        post :onsite_pay_confirm
        post :onsite_pay_create
        post :exchange_choose
        post :exchange_create
      end
    end

    scope module: "convention_setup" do
      resources :registration_periods, except: :show
      # /convention_setup/migrate
      # /convention_setup/migrate/from/:tenant
      # /convention_setup/migrate/from/:tenant/events
      # /convention_setup/migrate/from/:tenant/events POST
      # /convention_setup/migrate/from/:tenant/categories
      # /convention_setup/migrate/from/:tenant/categories POST
      namespace "migrate" do
        get :index, path: "/", controller: "migrations"
        scope "from/:tenant" do
          get :events, controller: "migrations"
          post :create_events, controller: "migrations"
        end
      end
    end

    resources :combined_competitions, except: :show, controller: "compete/combined_competitions" do
      resources :combined_competition_entries, except: [:show], controller: "compete/combined_competition_entries"
    end

    resources :coupon_code_summaries, only: [:show]

    resources :events, only: [] do
      collection do
        get :summary
        get "specific_volunteers/:volunteer_opportunity_id", action: :specific_volunteers, as: :specific_volunteers
        get :general_volunteers
      end
      member do
        get :sign_ups
      end
      scope module: "competition_setup" do
        resources :competitions, only: [:new, :create]
      end
    end
    resources :event_categories, only: [] do
      member do
        get :sign_ups
      end
    end

    get '/convention_setup', to: 'convention_setup#index'
    namespace :convention_setup do
      resources :categories, except: [:new, :show] do
        post :update_row_order, on: :collection
        resources :events, only: [:index, :create]
      end
      resources :events, except: [:index, :new, :create] do
        post :update_row_order, on: :collection

        resources :event_choices, only: [:index, :create] do
          post :update_row_order, on: :collection
        end

        resources :event_categories, only: [:index, :create] do
          post :update_row_order, on: :collection
        end
      end
      resources :event_choices, except: [:index, :create, :new, :show]
      resources :event_categories, except: [:index, :create, :new, :show]

      resources :volunteer_opportunities, except: [:show] do
        post :update_row_order, on: :collection
      end
    end
    scope "convention_setup", module: "convention_setup" do
      resources :coupon_codes, except: [:show]
    end

    get '/competition_setup', to: 'competition_setup#index'
    namespace :competition_setup do
      resource :event_configuration, only: [:edit, :update]
    end

    scope module: "competition_setup" do
      resources :directors, only: [:index, :create, :destroy]
    end

    get '/onsite_registration', to: 'onsite_registration#index'
    namespace :onsite_registration do
      resources :expense_groups, only: [:index] do
        member do
          put :toggle_visibility
        end
      end
    end

    # backwards-compatible URL
    get '/registrants/:id/items', to: redirect('/registrants/%{id}/registrant_expense_items')

    resources :emails, only: [:index, :create] do
      collection do
        get :list
      end
    end

    scope module: "admin" do
      resources :registrants, only: [] do
        collection do
          get :bag_labels
          get :show_all
          get :manage_all # How do I use cancan on this, if I were to name the action 'index'?
          get :manage_one
          post :choose_one
        end
        member do
          post :undelete
        end
      end
      resources :competition_songs, only: [:show, :create] do
        get :download_zip
      end
      resources :event_songs, only: [:index, :show, :create] do
        collection do
          get :all
        end
      end
    end

    resources :registrants, only: [:show, :destroy] do
      resources :build, controller: 'registrants/build', only: [:index, :show, :update, :create] do
        collection do
          delete :drop_event
        end
      end

      # normal user
      collection do
        get :all
        get :empty_waiver
        get :subregion_options
      end
      member do
        get :results
        get :waiver
      end
      resources :registrant_expense_items, only: [:create, :destroy]
      resources :standard_skill_routines, only: [:index, :create]
      member do
        get :payments, to: "payments#registrant_payments"
      end
      resources :songs, only: [:index, :create]
      resources :competition_wheel_sizes, only: [:index, :create, :destroy]
    end

    resources :songs, only: [:destroy] do
      member do
        get :add_file
        get :file_complete
      end
    end

    resources :standard_skill_routines, only: [:show, :index] do
      resources :standard_skill_routine_entries, only: [:destroy, :create]
    end
    resources :standard_skill_entries, only: [:index]

    # for AJAX use:
    resources :registrant_expenses, only: [] do
      collection do
        post 'single'
      end
    end

    resource :event_configuration, except: [:show, :new, :edit, :create, :update] do
      collection do
        get :cache
        delete :clear_cache
        delete :clear_counter_cache
        post :test_mode_role
      end

      collection do
        EventConfigurationsController::EVENT_CONFIG_PAGES.each do |page|
          get page
          put "update_#{page}"
        end
      end
    end

    get "usa_memberships", to: "usa_memberships#index"
    put "usa_memberships", to: "usa_memberships#update"
    get "usa_memberships/export", to: "usa_memberships#export"
    put "usa_memberships/update_number", to: "usa_memberships#update_number"

    resources :results, only: [:index] do
      collection do
        get :registrant
      end
      member do
        get :scores
      end
    end
    # get "results", to: "results#index"
    get "welcome/help"
    post "welcome/feedback"
    get "welcome/confirm"
    get 'welcome/data_entry_menu'

    devise_for :users, controllers: { registrations: "registrations" }

    resources :users, only: [] do
      resources :registrants, only: [:index]
      resources :payments, only: [:index]
      resources :additional_registrant_accesses, only: [:index, :new, :create] do
        collection do
          get :invitations
        end
      end
      resources :competition, only: [] do
        # resources :single_attempt_entries, only: [:index, :create]
        resources :two_attempt_entries, only: [:index, :create] do
          collection do
            get :proof
            post :approve
          end
        end

        resources :import_results, only: [:create] do
          collection do
            # These 2 don't use @user, move them?
            get :review
            post :approve

            get  :data_entry
            get :import_csv, as: "display_csv", action: :display_csv
            post :import_csv
            get :import_chip, as: "display_chip", action: :display_chip
            post :import_chip
            delete :destroy_all
          end
        end
      end
      resources :award_labels, shallow: true, except: [:new, :show] do
        collection do
          post :create_by_competition
          post :create_labels
          get :normal_labels
          delete :destroy_all
          get :announcer_sheet
        end
      end
      resources :songs, only: [] do
        collection do
          get :my_songs
          post :create_guest_song
        end
      end
    end
    resources :additional_registrant_accesses, only: [] do
      member do
        put :accept_readonly
        delete :decline
      end
    end
    resources :import_results, only: [:edit, :update, :destroy]
    resources :two_attempt_entries, only: [:edit, :update, :destroy]

    ###############################################
    ### For event-data-gathering/reporting purposes
    ###############################################

    resources :competitors, only: [:edit, :update, :destroy] do
      put :withdraw, on: :member
      post :update_row_order, on: :collection
    end

    scope module: "compete" do
      resources :ineligible_registrants, only: [:index, :create, :destroy]
    end

    scope module: "competition_setup" do
      resources :competitions, only: [:edit, :update, :destroy]
    end
    resources :competitions, only: [:show] do
      member do
        get :set_sort
        put :toggle_final_sort
        post :sort_random
        post :set_age_group_places
        post :set_places
        get :export_scores
        get :export_times
        # view scores
        get :result
        delete :destroy_all_results

        post :lock
        delete :unlock
        post :publish
        delete :publish, to: 'competitions#unpublish'
        post :publish_age_group_entry
        post :award
        delete :award
      end
      resources :competition_results, only: [:index, :create, :destroy]
      resources :competitors, only: [:index, :new, :create] do
        collection do
          post :add
          post :add_all
          delete :destroy_all
          get :display_candidates
          post :create_from_candidates
        end
      end
      scope module: "compete" do
        resource :sign_ins, only: [:show, :edit, :update]
        resource :wave_assignments, only: [:show, :update]
        resources :wave_times
      end

      resources :waves, only: [:index]
      resources :heats, only: [:index, :new, :create] do
        collection do
          # Track (LaneAssignments)
          delete :destroy_all

          get "age_group_entries/:age_group_entry_id/set_sort", to: "heats#set_sort", as: "set_sort"
          post "age_group_entries/:age_group_entry_id/set_sort", to: "heats#sort", as: "sort"
        end
      end

      resources :data_entry_volunteers, only: [:index, :create]
      resources :volunteers, only: [:index, :destroy] do
        collection do
          post ":volunteer_type", action: :create, as: :create
          delete ":volunteer_type", action: :destroy, as: :destroy
        end
      end

      resources :judges,      only: [:index, :create, :destroy] do
        collection do
          post :copy_judges
        end
      end
      resources :time_results, only: [:index, :create]
      resources :lane_assignments, only: [:index, :create] do
        collection do
          get :view_heat
          post :dq_competitor
          get :review
          get :download_heats_evt
        end
      end
      resources :heat_review, param: :heat, only: [:index, :show, :destroy] do
        member do
          post :approve_heat
          post :import_lif
        end
      end
      resources :distance_attempts, only: [] do
        collection do
          get :list
        end
      end
      resources :heat_lane_results, shallow: true, only: [:edit, :update, :create, :destroy]
      resources :heat_lane_judge_notes, only: [] do
        member do
          put :merge
        end
      end
      resources :external_results, shallow: true, except: [:new, :show]
      resources :preliminary_external_results, shallow: true, except: [:new, :show] do
        collection do
          get :review
          post :approve
          get :display_csv
          post :import_csv
        end
      end
      resources :published_age_group_entries, only: [:show] do
        member do
          get :preview
        end
      end
    end
    resources :lane_assignments, except: [:new, :index, :create, :show]

    resources :time_results, except: [:index, :new, :show, :create]

    resources :judges, only: [:update] do
      member do
        put :toggle_status
      end

      resources :competitors, only: [] do
        resources :scores, only: [:new, :create]

        # display chosen competitors current scores, and update them
        resources :standard_scores, only: [:new, :create]
      end

      # choose the desired competitor to add scores to
      resources :scores, only: [:index]
      resources :standard_scores, only: [:index]
      resources :distance_attempts, only: [:index, :create] do
        collection do
          get :competitor_details
        end
      end
      resources :tie_break_adjustments, only: [:index, :create]
      resources :street_scores, only: [:index, :destroy] do
        collection do
          post :update_score
        end
      end
    end
    resources :distance_attempts, only: [:destroy]
    resources :tie_break_adjustments, only: [:destroy]
  end

  resources :admin_upgrades, only: [:new, :create]
  resources :tenants, only: [:index, :create]
  resources :tenant_aliases, only: [:index, :create, :destroy] do
    member do
      post :verify
      post :activate
    end
  end
  resources :styles, only: :index

  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

  get '/:locale' => 'welcome#index' # to match /en  to send to /en/welcome
  root to: 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  fallback_options = Rails.env.development? ? { unmatched_route: /(?!.*rails\/mailers).*/ } : {}
  get '*unmatched_route', fallback_options.merge(to: 'application#raise_not_found!')
end
