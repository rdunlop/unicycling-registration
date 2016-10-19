# Creates accessor for additional information
# Either as a URL, or as a "Page"
# provides a .additional_info? method
module PageOrUrlLink
  extend ActiveSupport::Concern

  included do
    belongs_to :info_page, class_name: "Page"

    validate :only_one_info_type
  end

  def additional_info?
    info_url.present? || info_page.present?
  end

  private

  def only_one_info_type
    if info_url.present? && info_page.present?
      errors.add(:info_page_id, "Unable to specify both Info URL and Info Page")
    end
  end
end
