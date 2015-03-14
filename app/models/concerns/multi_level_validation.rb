#
# This Concern allows for multiple validations to be applied to an object
# It provides 2 things:
# 1. Partial-object validation functions
# 2. Controller-helper for enabling a set of validations semi-permanently.
#
# Example Use:
#
# class EventConfiguration
#   include MultiLevelValidation
#
#   specify_validations :base_settings, :payment_settings
#   validates :short_name, presence: true, if: base_settings_applied?
#   validates :payment_email, presence: true, if: payment_settings_applied?
#
# end
#
# class EventConfigurationsController
#   def update
#      @event_configuration.update_attributes(attributes)
#      @event_configuration.apply_validation(:base_settings)
#      @event_configuration.save
#   end
# end

module MultiLevelValidation
  extend ActiveSupport::Concern

  included do
  end

  def apply_validation(step_name)
    index = get_step_index(step_name)
    self.validations_applied ||= 0 # deal with nil
    self.validations_applied |= (1 << index)
  end

  private

  def is_step_applied?(step_name)
    return false if validations_applied.nil?
    index = get_step_index(step_name)
    (validations_applied & (1 << index)) != 0
  end

  def get_step_index(step_name)
    index = step_names.find_index(step_name)
    raise StandardError("step not defined #{step_name}") if index.nil?
    index
  end

  module ClassMethods
    def specify_validations(*step_names)
      define_method("step_names") do
        step_names
      end

      step_names.each do |step|
        define_method("#{step}_applied?") do
          is_step_applied?(step)
        end
      end
    end
  end
end
