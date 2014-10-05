# == Schema Information
#
# Table name: expense_groups
#
#  id                         :integer          not null, primary key
#  group_name                 :string(255)
#  visible                    :boolean
#  position                   :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  info_url                   :string(255)
#  competitor_free_options    :string(255)
#  noncompetitor_free_options :string(255)
#  competitor_required        :boolean          default(FALSE)
#  noncompetitor_required     :boolean          default(FALSE)
#  admin_visible              :boolean          default(FALSE)
#

class ExpenseGroup < ActiveRecord::Base
  validates :group_name, :presence => true
  validates :visible, :competitor_required, :noncompetitor_required, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :expense_items, -> {order "expense_items.position"}, :inverse_of => :expense_group

  translates :group_name
  accepts_nested_attributes_for :translations

  def self.free_options
    ["None Free", "One Free In Group", "One Free of Each In Group"]
  end

  validates :competitor_free_options, :inclusion => { :in => self.free_options, :allow_blank => true }
  validates :noncompetitor_free_options, :inclusion => { :in => self.free_options, :allow_blank => true }

  default_scope { order('position ASC') }
  scope :visible, -> { where(:visible => true) }

  def self.admin_visible
    where("visible = true or admin_visible = true")
  end

  after_initialize :init

  def init
    self.competitor_required = false if self.competitor_required.nil?
    self.noncompetitor_required = false if self.competitor_required.nil?
  end

  def self.for_competitor_type(is_competitor)
    if is_competitor
      where({:competitor_required => true})
    else
      where({:noncompetitor_required => true})
    end
  end

  def to_s
    group_name
  end
end
