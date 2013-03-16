# RailsAdmin config file. Generated on March 16, 2013 22:26
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Workspace', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user } # auto-generated

  config.authorize_with :cancan
  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['AgeGroupType', 'Category', 'Event', 'EventChoice', 'EventConfiguration', 'ExpenseGroup', 'ExpenseItem', 'Payment', 'PaymentDetail', 'Registrant', 'RegistrantChoice', 'RegistrantExpenseItem', 'RegistrationPeriod', 'Role', 'StandardSkillEntry', 'StandardSkillRoutine', 'StandardSkillRoutineEntry', 'User']

  # Include specific models (exclude the others):
  # config.included_models = ['AgeGroupType', 'Category', 'Event', 'EventChoice', 'EventConfiguration', 'ExpenseGroup', 'ExpenseItem', 'Payment', 'PaymentDetail', 'Registrant', 'RegistrantChoice', 'RegistrantExpenseItem', 'RegistrationPeriod', 'Role', 'StandardSkillEntry', 'StandardSkillRoutine', 'StandardSkillRoutineEntry', 'User']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:



  ###  AgeGroupType  ###

  # config.model 'AgeGroupType' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your age_group_type.rb model definition

  #   # Found associations:



  #   # Found columns:

  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :description, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Category  ###

  # config.model 'Category' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your category.rb model definition

  #   # Found associations:

  #     configure :events, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :position, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :info_url, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Event  ###

  # config.model 'Event' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your event.rb model definition

  #   # Found associations:

  #     configure :category, :belongs_to_association 
  #     configure :event_choices, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :category_id, :integer         # Hidden 
  #     configure :description, :string 
  #     configure :position, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  EventChoice  ###

  # config.model 'EventChoice' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your event_choice.rb model definition

  #   # Found associations:

  #     configure :event, :belongs_to_association 
  #     configure :registrant_choices, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :event_id, :integer         # Hidden 
  #     configure :export_name, :string 
  #     configure :cell_type, :string 
  #     configure :multiple_values, :string 
  #     configure :label, :string 
  #     configure :position, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :autocomplete, :boolean 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  EventConfiguration  ###

  # config.model 'EventConfiguration' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your event_configuration.rb model definition

  #   # Found associations:



  #   # Found columns:

  #     configure :id, :integer 
  #     configure :short_name, :string 
  #     configure :long_name, :string 
  #     configure :location, :string 
  #     configure :dates_description, :string 
  #     configure :event_url, :string 
  #     configure :start_date, :date 
  #     configure :currency, :string 
  #     configure :contact_email, :string 
  #     configure :closed, :boolean 
  #     configure :artistic_closed_date, :date 
  #     configure :standard_skill_closed_date, :date 
  #     configure :tshirt_closed_date, :date 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :logo_filename, :string 
  #     configure :logo_type, :string 
  #     configure :test_mode, :boolean 
  #     configure :waiver_url, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  ExpenseGroup  ###

  # config.model 'ExpenseGroup' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your expense_group.rb model definition

  #   # Found associations:

  #     configure :expense_items, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :group_name, :string 
  #     configure :visible, :boolean 
  #     configure :position, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :info_url, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  ExpenseItem  ###

  # config.model 'ExpenseItem' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your expense_item.rb model definition

  #   # Found associations:

  #     configure :expense_group, :belongs_to_association 
  #     configure :payment_details, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :description, :string 
  #     configure :cost, :decimal 
  #     configure :export_name, :string 
  #     configure :position, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :expense_group_id, :integer         # Hidden 
  #     configure :has_details, :boolean 
  #     configure :details_label, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Payment  ###

  # config.model 'Payment' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your payment.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association 
  #     configure :versions, :has_many_association         # Hidden 
  #     configure :payment_details, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
  #     configure :completed, :boolean 
  #     configure :cancelled, :boolean 
  #     configure :transaction_id, :string 
  #     configure :completed_date, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :payment_date, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  PaymentDetail  ###

  # config.model 'PaymentDetail' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your payment_detail.rb model definition

  #   # Found associations:

  #     configure :payment, :belongs_to_association 
  #     configure :registrant, :belongs_to_association 
  #     configure :expense_item, :belongs_to_association 
  #     configure :versions, :has_many_association         # Hidden 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :payment_id, :integer         # Hidden 
  #     configure :registrant_id, :integer         # Hidden 
  #     configure :amount, :decimal 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :expense_item_id, :integer         # Hidden 
  #     configure :details, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Registrant  ###

  # config.model 'Registrant' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your registrant.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association 
  #     configure :versions, :has_many_association         # Hidden 
  #     configure :registrant_choices, :has_many_association 
  #     configure :event_choices, :has_many_association 
  #     configure :events, :has_many_association 
  #     configure :categories, :has_many_association 
  #     configure :registrant_expense_items, :has_many_association 
  #     configure :expense_items, :has_many_association 
  #     configure :payment_details, :has_many_association 
  #     configure :standard_skill_routine, :has_one_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :first_name, :string 
  #     configure :middle_initial, :string 
  #     configure :last_name, :string 
  #     configure :birthday, :date 
  #     configure :gender, :string 
  #     configure :state, :string 
  #     configure :country, :string 
  #     configure :phone, :string 
  #     configure :mobile, :string 
  #     configure :email, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :user_id, :integer         # Hidden 
  #     configure :competitor, :boolean 
  #     configure :club, :string 
  #     configure :club_contact, :string 
  #     configure :usa_member_number, :string 
  #     configure :emergency_name, :string 
  #     configure :emergency_relationship, :string 
  #     configure :emergency_attending, :boolean 
  #     configure :emergency_primary_phone, :string 
  #     configure :emergency_other_phone, :string 
  #     configure :responsible_adult_name, :string 
  #     configure :responsible_adult_phone, :string 
  #     configure :address, :string 
  #     configure :city, :string 
  #     configure :zip, :string 
  #     configure :deleted, :boolean 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  RegistrantChoice  ###

  # config.model 'RegistrantChoice' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your registrant_choice.rb model definition

  #   # Found associations:

  #     configure :registrant, :belongs_to_association 
  #     configure :event_choice, :belongs_to_association 
  #     configure :versions, :has_many_association         # Hidden 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :registrant_id, :integer         # Hidden 
  #     configure :event_choice_id, :integer         # Hidden 
  #     configure :value, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  RegistrantExpenseItem  ###

  # config.model 'RegistrantExpenseItem' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your registrant_expense_item.rb model definition

  #   # Found associations:

  #     configure :registrant, :belongs_to_association 
  #     configure :expense_item, :belongs_to_association 
  #     configure :versions, :has_many_association         # Hidden 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :registrant_id, :integer         # Hidden 
  #     configure :expense_item_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :details, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  RegistrationPeriod  ###

  # config.model 'RegistrationPeriod' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your registration_period.rb model definition

  #   # Found associations:

  #     configure :competitor_expense_item, :belongs_to_association 
  #     configure :noncompetitor_expense_item, :belongs_to_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :start_date, :date 
  #     configure :end_date, :date 
  #     configure :name, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :competitor_expense_item_id, :integer         # Hidden 
  #     configure :noncompetitor_expense_item_id, :integer         # Hidden 
  #     configure :onsite, :boolean 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Role  ###

  # config.model 'Role' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your role.rb model definition

  #   # Found associations:

  #     configure :resource, :polymorphic_association         # Hidden 
  #     configure :users, :has_and_belongs_to_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :resource_id, :integer         # Hidden 
  #     configure :resource_type, :string         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  StandardSkillEntry  ###

  # config.model 'StandardSkillEntry' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your standard_skill_entry.rb model definition

  #   # Found associations:

  #     configure :standard_skill_routine_entries, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :number, :integer 
  #     configure :letter, :string 
  #     configure :points, :decimal 
  #     configure :description, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  StandardSkillRoutine  ###

  # config.model 'StandardSkillRoutine' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your standard_skill_routine.rb model definition

  #   # Found associations:

  #     configure :registrant, :belongs_to_association 
  #     configure :standard_skill_routine_entries, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :registrant_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  StandardSkillRoutineEntry  ###

  # config.model 'StandardSkillRoutineEntry' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your standard_skill_routine_entry.rb model definition

  #   # Found associations:

  #     configure :standard_skill_routine, :belongs_to_association 
  #     configure :standard_skill_entry, :belongs_to_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :standard_skill_routine_id, :integer         # Hidden 
  #     configure :standard_skill_entry_id, :integer         # Hidden 
  #     configure :position, :integer 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  User  ###

  # config.model 'User' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your user.rb model definition

  #   # Found associations:

  #     configure :roles, :has_and_belongs_to_many_association 
  #     configure :versions, :has_many_association         # Hidden 
  #     configure :registrants, :has_many_association 
  #     configure :payments, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :email, :string 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :string         # Hidden 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :string 
  #     configure :last_sign_in_ip, :string 
  #     configure :confirmation_token, :string 
  #     configure :confirmed_at, :datetime 
  #     configure :confirmation_sent_at, :datetime 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :club_admin, :boolean 
  #     configure :club, :string 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

end
