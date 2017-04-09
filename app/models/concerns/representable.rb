module Representable
  extend ActiveSupport::Concern

  def representation
    RepresentationType.new(self).to_s
  end
end
