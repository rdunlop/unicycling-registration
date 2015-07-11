module PunditViewPolicy
  extend ActiveSupport::Concern

  included do
    before do
      controller.singleton_class.class_eval do
        def policy(instance)
          Class.new do
            def method_missing(*args, &block); true; end
          end.new
        end
        helper_method :policy
      end
    end
  end
end

RSpec.configure do |config|
  config.include PunditViewPolicy, type: :view
end
