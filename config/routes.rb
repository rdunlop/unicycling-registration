Rails.application.routes.draw do
  mount Tolk::Engine => '/tolk', :as => 'tolk'
  require 'sidekiq/web'
  authenticate :user, ->(u) { u.has_role?(:super_admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end
  mount ApartmentAcmeClient::Engine => '/aac'

  get '404', to: 'errors#not_found'
  get '415', to: 'errors#not_found'
  get '422', to: 'errors#not_permitted'
  get '500', to: 'errors#internal_server_error'

  scope "(:locale)" do
    resources :registrant_group_types, only: [:index] do
      shallow do
        resources :registrant_groups do
          resources :registrant_group_members, only: %i[create destroy] do
            member do
              post :promote
              post :request_leader
            end
          end
          resources :registrant_group_leaders, only: %i[create destroy]
        end
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
          get :freestyle_summary
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
    resources :age_group_types, except: [:new], controller: "competition_setup/age_group_types" do
      member do
        post :duplicate
      end
    end

    resources :age_group_entries, only: [], controller: "competition_setup/age_group_entries" do
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
      resource :event_configuration, only: %i[edit update]
      resources :categories, only: %i[index edit update]
      resources :events, only: %i[index edit update]
      resources :event_categories, only: %i[index edit update]
      resources :event_choices, only: %i[index edit update]
      resources :pages, only: %i[index edit update]
      resources :expense_groups, only: %i[index edit update]
      resources :expense_items, only: %i[index edit update]
      resources :registration_costs, only: %i[index edit update]
    end

    namespace :export do
      get :index
      get :download_payment_details
      get :download_all_payments, controller: "/export_registrants", action: "download_with_payment_details"
      get :download_all_registrants, controller: "/export_registrants", action: "download_all"
      get :download_summaries, controller: "/export_registrants"
      get :download_events
      get :download_competitors_for_timers
      get :download_registrants
      get :results
    end
    resources :imports, only: %i[index new create] do
      collection do
        post :import_registrants
      end
    end

    resources :standard_skill_entries, only: [:index]

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
      resources :expense_items, except: %i[new show], controller: "convention_setup/expense_items"
    end

    resources :expense_items, only: [], controller: "convention_setup/expense_items" do
      post :update_row_order, on: :collection
    end

    resources :refunds, only: [:show]

    resources :pages, only: [:show], param: :slug

    resource :export_payments, only: [] do
      collection do
        get :list
        put :payments
        put :payment_details
      end
    end

    get  "/payments/set_reg_fees", controller: "admin/reg_fees", action: :index, as: "set_reg_fees"
    post "/payments/update_reg_fee", controller: "admin/reg_fees", action: :update_reg_fee, as: "update_reg_fee"

    namespace :payment_summary do
      resources :expense_groups, only: %i[index show]
      resources :expense_items, only: [] do
        member do
          get :details
        end
      end
    end

    resources :payments, except: %i[index edit update destroy] do
      collection do
        get :summary
        post :notification, controller: "paypal_payments"
        get :success, controller: "paypal_payments"
        get :offline
      end

      member do
        post :fake_complete
        post :complete
        post :admin_complete
        post :pay_offline
        post :apply_coupon
      end
    end
    resources :pending_payments, only: [], controller: "admin/pending_payments" do
      member do
        post :pay
      end
    end
    resources :manual_payments, only: %i[new create], controller: "admin/manual_payments" do
      collection do
        get :choose
      end
    end
    resources :manual_refunds, only: %i[new create], controller: "admin/manual_refunds" do
      collection do
        get :choose
      end
    end

    resources :payment_adjustments, only: [:new] do
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
      resources :registration_costs, except: :show
      resource :event_configuration, only: [] do
        collection do
          get :cache
          delete :clear_cache
          delete :clear_counter_cache
          post :test_mode_role
        end

        collection do
          ConventionSetup::EventConfigurationsController::EVENT_CONFIG_PAGES.each do |page|
            get page
            put "update_#{page}"
          end
        end
      end
      resources :tenant_aliases, only: %i[index create destroy] do
        member do
          put :confirm_url
          get :verify
          post :activate
        end
      end
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

    # This concern is exposed to the public for describing the system
    # as well as to Competition Admins for creating competitions
    concern :competition_choosable do
      resources :competition_choices, only: [:index], controller: "/example/competition_choices" do
        collection do
          get :freestyle
          get :individual
          get :pairs
          get :group
          get :standard_skill
          get :high_long
          get :timed
          get :points
          get :flatland
          get :street
          get :overall_champion
          get :custom
          get :download_file
          get :director_responsibilities
        end
      end
    end

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
        resources :competitions, only: %i[new create]
        concerns :competition_choosable
      end
    end
    resources :event_categories, only: [] do
      member do
        get :sign_ups
      end
      resources :best_times, only: %i[index update destroy]
    end

    get '/convention_setup', to: 'convention_setup/convention_setup#index'
    get '/convention_setup/costs', to: 'convention_setup/convention_setup#costs'
    namespace :convention_setup do
      resources :categories, except: %i[new show] do
        post :update_row_order, on: :collection
        resources :events, only: %i[index create]
      end
      resources :events, except: %i[index new create] do
        post :update_row_order, on: :collection

        resources :event_choices, only: %i[index create] do
          post :update_row_order, on: :collection
        end

        resources :event_categories, only: %i[index create] do
          post :update_row_order, on: :collection
        end
      end
      resources :event_choices, except: %i[index create new show]
      resources :event_categories, except: %i[index create new show]

      resources :registrant_group_types

      resources :volunteer_opportunities, except: [:show] do
        post :update_row_order, on: :collection
      end
      resources :pages do
        resources :images, only: %i[index create destroy]
      end
    end
    scope "convention_setup", module: "convention_setup" do
      resources :coupon_codes, except: [:show]
    end

    get '/competition_setup', to: 'competition_setup#index'
    namespace :competition_setup do
      resource :event_configuration, only: %i[edit update]
    end

    scope module: "competition_setup" do
      resources :directors, only: %i[index create destroy]
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

    resources :emails, only: %i[index create] do
      collection do
        get :list
        get :download
        get :all_sent
      end

      member do
        get :sent
      end
    end

    namespace :admin do
      resources :feedback, only: %i[index show new create] do
        member do
          put :resolve
        end
      end
    end

    scope module: "admin" do
      resources :registrants, only: [] do
        collection do
          get :manage_all # How do I use cancan on this, if I were to name the action 'index'?
          get :manage_one
          post :choose_one
          get :change_registrant_user
          put :set_registrant_user
        end
        member do
          post :undelete
          delete :really_destroy
        end
      end

      resources :bag_labels, only: %i[index create]
      resources :registrant_summaries, only: %i[index create]
      resources :bib_numbers, only: %i[index create]
      resources :reports, only: [:index]
      resources :competition_songs, only: %i[show create], param: :competition_id do
        member do
          get :download_zip
        end
      end
      resources :event_songs, only: %i[index show create] do
        collection do
          get :all
        end
      end

      resources :standard_skill_routines, only: [] do
        collection do
          get :view_all
          get :download_file
        end
      end
    end

    resources :registrants, only: %i[new show destroy] do
      resources :build, controller: 'registrants/build', only: %i[index show update create] do
        collection do
          post :create_from_previous
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
        put :refresh_usa_status
        post :copy_to_competitor
        post :copy_to_noncompetitor
      end
      resources :registrant_expense_items, only: %i[create destroy]
      resources :standard_skill_routines, only: [:create]
      member do
        get :payments, to: "payments#registrant_payments"
      end
      resources :songs, only: %i[index create]
      resources :competition_wheel_sizes, only: %i[index create destroy]
    end

    resources :songs, only: [:destroy]

    resources :standard_skill_routines, only: %i[show index] do
      member do
        get :writing_judge
        get :difficulty_judge
        get :execution_judge
      end
      resources :standard_skill_routine_entries, only: %i[destroy create]
    end
    resources :standard_skill_entries, only: [:index]

    resources :organization_memberships, only: [:index] do
      member do
        put :toggle_confirm
        put :update_number
        post :refresh_usa_status
      end
      collection do
        get :export
      end
    end

    resources :results, only: [:index] do
      collection do
        get :registrant
      end
      member do
        get :scores
        get :distances
      end
    end
    # get "results", to: "results#index"
    resource :feedback, only: %i[new create]
    resource :welcome, only: [], controller: "welcome" do
      collection do
        get :changelog
        get :help_translate
        get :help
        get :confirm
        get :data_entry_menu
        get :usa_membership
        get :passwords
      end
    end

    devise_for :users, controllers: { registrations: "devise/custom_registrations", passwords: "devise/custom_passwords" }

    resources :users, only: [] do
      resources :registrants, only: [:index]
      resources :payments, only: [:index]
      resources :additional_registrant_accesses, only: %i[index new create] do
        collection do
          get :invitations
        end
      end
      resources :competition, only: [] do
        # resources :single_attempt_entries, only: [:index, :create]
        resources :two_attempt_entries, only: %i[index create] do
          collection do
            get :proof
            post :approve
            get :display_csv
            post :import_csv
          end
        end

        resources :import_results, only: [:create] do
          collection do
            # These 2 don't use @user, move them?
            get :review
            post :approve

            get  :data_entry
            get :display_csv
            post :import_csv
            get :display_chip
            post :import_chip
            delete :destroy_all
          end
        end
        resources :swiss_results, only: [:index] do
          collection do
            post :import
            post :approve
            delete :destroy_all
          end
          patch :dq_single
        end
      end
      resources :award_labels, shallow: true, except: %i[new show] do
        collection do
          post :create_by_competition
          post :create_generic_by_competition
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
    resources :import_results, only: %i[edit update destroy]
    resources :two_attempt_entries, only: %i[edit update destroy]

    ###############################################
    ### For event-data-gathering/reporting purposes
    ###############################################

    resources :competitors, only: %i[edit update destroy] do
      put :withdraw, on: :member
      post :update_row_order, on: :collection
    end

    scope module: "compete" do
      resources :ineligible_registrants, only: %i[index create destroy]
    end

    scope module: "competition_setup" do
      resources :competitions, only: %i[edit update destroy]
    end
    resources :competitions, only: [:show] do
      member do
        get :set_sort
        put :toggle_final_sort
        post :sort_random
        post :set_age_group_places
        post :set_places
        get :export
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
        post :create_last_minute_competitor
        put :refresh_competitors
      end
      resources :competition_results, only: %i[index create destroy]
      resources :uploaded_files, only: %i[index show]
      resources :competitors, only: %i[index new create] do
        collection do
          post :add
          post :add_all
          delete :destroy_all
        end
      end
      resources :candidates, only: [:index] do
        collection do
          post :create_from_candidates
        end
      end
      scope module: "compete" do
        resource :sign_ins, only: %i[show edit update]
        resource :wave_assignments, only: %i[show update]
        resource :tier_assignments, only: %i[show update]
        resources :wave_times, except: %i[new show]
        resource :age_groups, only: [:show] do
          member do
            post :duplicate_type
            put :combine
          end
        end
      end

      resources :waves, only: [:index]
      resources :heats, only: %i[index new create] do
        collection do
          # Track (LaneAssignments)
          delete :destroy_all

          get "age_group_entries/:age_group_entry_id/set_sort", to: "heats#set_sort", as: "set_sort"
          post "age_group_entries/:age_group_entry_id/set_sort", to: "heats#sort", as: "sort"
        end
      end

      resources :data_entry_volunteers, only: %i[index create]
      resources :volunteers, only: %i[index destroy] do
        collection do
          post ":volunteer_type", action: :create, as: :create
          delete ":volunteer_type", action: :destroy, as: :destroy
        end
      end

      resources :judges, only: %i[index create destroy] do
        collection do
          post :copy_judges
        end
      end
      resources :time_results, only: %i[index create]
      resources :lane_assignments, only: %i[index create] do
        collection do
          get :view_heat
          post :dq_competitor
          get :review
        end
      end
      resources :heat_exports, only: [:index] do
        collection do
          get :download_evt
          get :download_competitor_list
          get :download_competitor_list_ssv
          post :download_heat_tsv
          post :download_all_heats_tsv
        end
      end

      resources :heat_review, param: :heat, only: %i[index show destroy] do
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
      resources :heat_lane_results, shallow: true, only: %i[edit update create destroy]
      resources :heat_lane_judge_notes, only: [] do
        member do
          put :merge
        end
      end
      resources :external_results, shallow: true, except: %i[new show]
      resources :preliminary_external_results, shallow: true, except: %i[new show] do
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
    resources :lane_assignments, except: %i[new index create show]

    resources :time_results, except: %i[index new show create]

    resources :judges, only: [] do
      member do
        put :toggle_status
      end

      resources :competitors, only: [] do
        resources :scores, only: %i[new create]

        # display chosen competitors current scores, and update them
        resources :standard_skill_scores, only: %i[new create edit update destroy]
      end

      # choose the desired competitor to add scores to
      resources :scores, only: [:index]
      resources :standard_skill_scores, only: [:index]
      resources :distance_attempts, only: %i[index create] do
        collection do
          get :competitor_details
        end
      end
      resources :tie_break_adjustments, only: %i[index create]
      resources :street_scores, only: %i[index destroy] do
        collection do
          post :update_order
          post :set_rank
        end
      end
    end
    resources :distance_attempts, only: [:destroy]
    resources :tie_break_adjustments, only: [:destroy]
  end

  resources :admin_upgrades, only: %i[new create]
  resources :tenants, only: %i[index new create]

  namespace :sample_data do
    resources :registrants, only: %i[index create]
    resources :competitions, only: %i[index create]
  end

  namespace :example do
    resource :description, only: :show
    resources :convention_choices, only: :index do
      collection do
        get :standard_skill
      end
    end
    concerns :competition_choosable
  end

  resources :styles, only: :index
  get "/new", to: redirect("/tenants")

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
