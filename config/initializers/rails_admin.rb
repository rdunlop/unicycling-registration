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

  config.authorize_with :pundit
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
end

module RailsAdmin
  module Extensions
    module Pundit
      class AuthorizationAdapter
        def authorize(action, abstract_model = nil, model_object = nil)
          record = model_object || abstract_model&.model
          if action && !policy(record).send(*action_for_pundit(action)) # Added splat
            raise ::Pundit::NotAuthorizedError.new("not allowed to #{action} this #{record}")
          end
          @controller.instance_variable_set(:@_pundit_policy_authorized, true)
        end

        def authorized?(action, abstract_model = nil, model_object = nil)
          record = model_object || abstract_model&.model
          policy(record).send(*action_for_pundit(action)) if action # Added splat
        end

        def action_for_pundit(action)
          [:rails_admin?, action]
        end
      end
    end
  end
end
