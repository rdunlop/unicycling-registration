# == Schema Information
#
# Table name: expense_groups
#
#  id                         :integer          not null, primary key
#  visible                    :boolean          default(TRUE), not null
#  position                   :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  info_url                   :string(255)
#  competitor_free_options    :string(255)
#  noncompetitor_free_options :string(255)
#  competitor_required        :boolean          default(FALSE), not null
#  noncompetitor_required     :boolean          default(FALSE), not null
#  registration_items         :boolean          default(FALSE), not null
#  info_page_id               :integer
#  system_managed             :boolean          default(FALSE), not null
#

class ExpenseGroup < ApplicationRecord
  include PageOrUrlLink

  validates :group_name, presence: true
  validates :visible, :competitor_required, :noncompetitor_required, inclusion: { in: [true, false] } # because it's a boolean

  has_many :expense_items, -> {order "expense_items.position"}, inverse_of: :expense_group
  has_many :expense_group_free_options, inverse_of: :expense_group

  translates :group_name, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations
  accepts_nested_attributes_for :expense_group_free_options, allow_destroy: true

  # def self.free_options
  #   ["None Free", "One Free In Group", "One Free In Group REQUIRED", "One Free of Each In Group"]
  # end

  # validates :competitor_free_options, inclusion: { in: free_options, allow_blank: true }
  # validates :noncompetitor_free_options, inclusion: { in: free_options, allow_blank: true }

  default_scope { order(:position) }
  scope :visible, -> { where(visible: true).not_a_required_item_group }

  acts_as_restful_list scope: :registration_items # must keep the position for registration_items only

  def self.admin_visible
    user_manageable.not_a_required_item_group
  end

  # If an Item from this group is required (ie: automatically added).
  # Don't display the group in the list(s).
  def self.not_a_required_item_group
    where(competitor_required: false, noncompetitor_required: false)
  end

  # ################### SYSTEM MANAGED #######################
  def self.registration_items_group
    find_by(registration_items: true) || create_registration_items_group
  end

  def self.create_registration_items_group
    create(visible: false,
           system_managed: true,
           registration_items: true,
           competitor_required: false,
           noncompetitor_required: false,
           group_name: "Registration")
  end

  def self.event_items_group
    find_by(system_managed: true, registration_items: false) || create_event_items_group
  end

  def self.create_event_items_group
    create(visible: false,
           system_managed: true,
           registration_items: false,
           competitor_required: false,
           noncompetitor_required: false,
           group_name: "System-Event")
  end
  # ################### END SYSTEM MANAGED #######################

  def self.user_manageable
    where(system_managed: false)
  end

  def to_s
    group_name
  end
end
