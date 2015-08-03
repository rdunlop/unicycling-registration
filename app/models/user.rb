# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  guest                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  include ApplicationHelper
  rolify after_add: :touch_for_role, after_remove: :touch_for_role

  # Include default devise modules. Others available are:
  # :token_authenticatable
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :async,
         :recoverable, :rememberable, :trackable, :validatable

  devise :confirmable

  default_scope { order(:email) }

  has_paper_trail meta: {user_id: :id }

  has_many :registrants, -> { includes [:registrant_expense_items, :payment_details] }

  has_many :additional_registrant_accesses, dependent: :destroy
  has_many :invitations, through: :registrants, class_name: "AdditionalRegistrantAccess", source: :additional_registrant_accesses

  has_many :judges

  has_many :payments
  has_many :refunds

  has_many :import_results
  has_many :award_labels
  has_many :songs

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }
  scope :all_with_registrants, -> { where('id IN (SELECT DISTINCT(user_id) FROM registrants)') }

  def touch_for_role(_role)
    touch
  end

  # get all users who have registrants with unpaid fees
  def self.unpaid_reg_fees
    registrants = Registrant.active.reject(&:reg_paid?)
    registrants.map(&:user).flatten.uniq
  end

  def self.paid_reg_fees
    User.confirmed.all_with_registrants - User.unpaid_reg_fees
  end

  def self.roles
    # these should be sorted in order of least-priviledge -> Most priviledge
    [:late_registrant, :music_dj, :awards_admin, :event_planner, :translator,
      :membership_admin, :competition_admin, :payment_admin, :convention_admin, :super_admin]
  end

  # List which roles each roles can add to other users
  def self.role_transfer_permissions
    {
      super_admin: [*roles],
      convention_admin: [:convention_admin, :payment_admin, :event_planner, :music_dj, :membership_admin],
      competition_admin: [:competition_admin, :awards_admin],
      director: [],
      payment_admin: [:payment_admin, :late_registrant],
      event_planner: [:event_planner],
      music_dj: [:music_dj]
    }
  end

  def roles_accessible
    roles.map(&:name).each_with_object([]) do |role, array|
      new_roles = self.class.role_transfer_permissions[role.to_sym]
      array << new_roles if new_roles.present?
    end.flatten.uniq
  end

  def self.role_description(role)
    case (role)
      # when :results_printer
    when :convention_admin
      "[e.g. Olaf Scholte]
      Able to configure the Convention settings with regards to registration settings
      Can setup the look-and-feel, Convention Name, and Domain URL settings.
      Can set payment costs
      Can set the PayPal details
      Can set events offered
      Can set the volunteer options
      Can reset users passwords
      Can set up 'Authorized Laptops' for use in on-site registration
      Can create payment_admin, event_planner, and music_dj users
      "
    when :competition_admin
      "[e.g. Scott Wilton]
      Able to create competitions, and adjust competition configuration
      Able to create/manage Age Groups
      Can set registrants as ineligible
      Can create director, data_entry_volunteer
      Can reset user passwords
      Can View all Event Sign Ups
      Can Manage all Competition Competitors (while competition is unlocked)
      Can Lock/Unlock Competition
      "
    when :director
      "[e.g. Wendy Gryzch]
      Able to assign registrants to competitors
      Can create judges, volunteers
      Can reset user passwords
      "
    when :super_admin
      "[e.g. Robin] Able to set roles of other people, able to destroy payment information, able to configure the site settings, event settings"
    when :payment_admin
      "[e.g. Garrett Macey]
      Able to view the payments that have been received
      Able to see the total number of items paid.
      Able to Set Registration Fees per user
      Able to mark checks as received"
    when :event_planner
      "[e.g. Mary Koehler]
      Able to view/review the event sign_ups.
      Able to SEARCH & MODIFY any registration.
      Able to Add/Modify event choices, at all times.
      Able to view/send emails to all registrants"
    when :membership_admin
      "Able to view the USA Memberships page.
      Able to update the USA Membership numbers
      Able to indicate whether a user is up-to-date with USA membership fees"
    when :awards_admin
      "[e.g. Kirsten]
      Able to view the data results
      Able to publish results
      Able to mark competitions as awarded"
    when :music_dj
      "[e.g. JoAnn]
      Able to view/download any music from the Manage Music page"
    when :translator
      "[e.g. Olaf]
      Able to access the translation menu.
      Enter new translations, and apply them to the site"
    when :late_registrant
      "Able to access the registration system even after the registration period has closed.
      Able to Create new registrants, update existing registrants, and make payments.
      You should use this along with the SetRegFee function, to specify the fee they are to be charged.
      "
    else
      "No Description Available"
    end
  end

  # Public: A list of all possible data-entry roles, what is used on each
  # competition is dependent upon the type of competition
  POSSIBLE_DATA_VOLUNTEERS = [:race_official, :data_recording_volunteer, :track_data_importer]

  def self.volunteer_role_descriptions(role)
    case role
    when :data_entry_volunteer
      "Able to be assigned as data-recording volunteer"
    when :race_official
      "Able to DQ at start or end-line of Race
      Able to download heat-lists for Track E-Timers
      "
    when :track_data_importer
      "Able to import e-timer data for track day.
      Able to adjust time results"
    when :data_recording_volunteer
      "Able to enter Start/Finish Line results (transcribed)"
    else
      "No description"
    end
  end

  def self.data_entry_volunteer
    with_role(:data_entry_volunteer).reorder(:name)
  end

  def to_s
    name.presence || email
  end
  #   def additional_editable_registrants
  #     Registrant.active_or_incomplete.joins(:additional_registrant_accesses).merge(additional_registrant_accesses.full_access)
  #   end

  #   def additional_accessible_registrants
  #     Registrant.active_or_incomplete.joins(:additional_registrant_accesses).merge(additional_registrant_accesses.permitted)
  #   end

  def editable_registrants
    (additional_registrant_accesses.full_access.map(&:registrant) + registrants).reject(&:deleted?)
  end

  def accessible_registrants
    (additional_registrant_accesses.permitted.map(&:registrant) + registrants).reject(&:deleted?)
  end

  def total_owing
    accessible_registrants.inject(0){|memo, reg| memo + reg.amount_owing }
  end

  def has_minor?
    registrants.active.each do |reg|
      if reg.minor?
        return true
      end
    end
    false
  end
end
