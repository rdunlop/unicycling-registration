module HasDetailsDescription
  extend ActiveSupport::Concern

  def details_description
    "#{details_label}: #{details}" if has_details?
  end
end
