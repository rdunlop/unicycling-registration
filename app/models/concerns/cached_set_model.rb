#
# This Concern allows for caches to be specified over a subset of records in a model (according to a condition)
#
# Example Use:
#
# class PaymentDetail
#   include CachedSetModel
#   belongs_to :expense_item
#
#   def self.cache_set_field
#     :expense_item_id
#   end
# end
#
# .....
#
# cache [PaymentDetail.cache_key_for_set(12) ] do
#   # this will only burst whenever a payment_detail with expense_item_id == 12 is added/removed
# end
#

module CachedSetModel
  extend ActiveSupport::Concern

  included do
    if respond_to?(:after_save)
      after_save :update_last_modified_set_collection_cache
      after_destroy :do_touch_set
      after_touch :do_touch_set
    end
  end

  def recent_changes
    saved_changes.transform_values(&:first)
  end

  def update_last_modified_set_collection_cache
    return unless recent_changes.keys.any?
    do_touch_set
  end

  def element_value
    send(self.class.cache_set_field)
  end

  def do_touch_set
    self.class.touch_set(element_value)
    self.class.superclass.touch if self.class.superclass.respond_to? :touch
  end

  module ClassMethods
    def cache_key_for_set(element_value)
      last_modified = Rails.cache.fetch(cache_set_key_base(element_value)) do
        render_timestamp(Time.zone.now)
      end
      "#{cache_set_key_base(element_value)}/#{last_modified}"
    end

    def touch_set(element_value)
      timestamp = render_timestamp(Time.zone.now)
      Rails.cache.write(cache_set_key_base(element_value), timestamp)
    end

    def render_timestamp(time)
      time.utc.to_s(:number)
    end

    def cache_set_key_base(element_value)
      "#{model_name}/collection_subset/#{element_value}"
    end
  end
end
