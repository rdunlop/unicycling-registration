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
#  guest                  :boolean          default(FALSE)
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

  default_scope { order('email ASC') }

  has_paper_trail :meta => {:user_id => :id }

  has_many :registrants, -> { includes [:registrant_expense_items, :payment_details] }

  has_many :additional_registrant_accesses, :dependent => :destroy
  has_many :invitations, :through => :registrants, :class_name => "AdditionalRegistrantAccess", :source => :additional_registrant_accesses

  has_many :judges

  has_many :payments
  has_many :refunds

  has_many :import_results
  has_many :award_labels
  has_many :songs

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }
  scope :all_with_registrants, -> { where('id IN (SELECT DISTINCT(user_id) FROM registrants)') }

  def touch_for_role(role)
    touch
  end

  # get all users who have registrants with unpaid fees
  def self.unpaid_reg_fees
    registrants = Registrant.active.select { |reg| !reg.reg_paid? }
    registrants.map(&:user).flatten.uniq
  end

  def self.paid_reg_fees
    User.confirmed.all_with_registrants - User.unpaid_reg_fees
  end

  def self.roles
    # these should be sorted in order of least-priviledge -> Most priviledge
    [:normal_user, :music_dj, :awards_admin, :event_planner, :data_entry_volunteer, :payment_admin, :admin, :super_admin]
  end

  def self.role_description(role)
    case(role)
      #when :track_official
      #when :results_printer
    when :data_entry_volunteer
      "[e.g. Data Entry Volunteers] Able to view the Data Entry menu, and enter data for any event"
    when :admin
      "[e.g. Scott/Connie]
      Able to create onsite payments,
      adjust many details of the system.
      Able to send mass-email to various subsets of users.
      Can assign Directors, and do anything a director can do:
      - can create/assign judges
      Can assign data_entry_volunteers, and do anything they can do:
      - Can enter recorded Results
      Can Create Award Labels
      Can adjust wheel-size settings for users.
      "
    when :super_admin
      "[e.g. Robin] Able to set roles of other people, able to destroy payment information, able to configure the site settings, event settings"
    when :payment_admin
      "[e.g. Garrett Macey] Able to view the payments that have been received, the total number of items paid."
    when :event_planner
      "[e.g. Mary Koehler]
      Able to view/review the event sign_ups.
      Able to view/send emails to all registrants"
    when :awards_admin
      "[e.g. Kirsten]
      Able to view the data results
      Able to publish results
      Able to mark competitions as awarded"
    when :music_dj
      "[e.g. JoAnn]
      Able to view/download any music from the Manage Music page"
    when :normal_user
      "[e.g. John Smith] (no special abilities)"
    else
      "No Description Available"
    end
  end

  def to_s
    name || email
  end

  def editable_registrants
    (additional_registrant_accesses.full_access.map(&:registrant) + registrants).select{|reg| !reg.deleted}
  end

  def accessible_registrants
    (additional_registrant_accesses.permitted.map(&:registrant) + registrants).select{|reg| !reg.deleted}
  end

  def total_owing
    accessible_registrants.inject(0){|memo, reg| memo + reg.amount_owing }
  end

  def has_minor?
    self.registrants.active.each do |reg|
      if reg.minor?
        return true
      end
    end
    false
  end
end
