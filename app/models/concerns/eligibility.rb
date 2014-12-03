module Eligibility
  extend ActiveSupport::Concern

  def display_eligibility(name, ineligible)
    "#{name}#{ "*" if ineligible }"
  end
end
