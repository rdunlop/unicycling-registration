module CachedModel
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:after_save)
      after_save :update_last_modified_collection_cache
      after_destroy :do_touch
      after_touch :do_touch
    end
  end

  def update_last_modified_collection_cache
    return unless (changes.keys - ignored_for_collection_invalidation_fields).any?
    do_touch
  end

  def do_touch
    self.class.touch
    self.class.superclass.touch if self.class.superclass.respond_to? :touch
  end

  def ignored_for_collection_invalidation_fields
    []
  end

  module ClassMethods
    def cache_key
      last_modified = Rails.cache.fetch(cache_key_base) do
        render_timestamp(Time.zone.now)
      end
      "#{cache_key_base}/#{last_modified}"
    end

    def touch
      if ApplicationController.perform_caching
        timestamp = render_timestamp(Time.zone.now)
        Rails.cache.write(cache_key_base, timestamp)
      end
    end

    def render_timestamp(time)
      time.utc.to_s(:number)
    end

    def cache_key_base
      "#{model_name}/collection"
    end
  end
end
