module Slugify
  extend ActiveSupport::Concern

  def slug
    to_s.downcase.gsub(/[^0-9a-z]/, "_")
  end
end
