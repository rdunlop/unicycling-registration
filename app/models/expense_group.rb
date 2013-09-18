class ExpenseGroup < ActiveRecord::Base
  attr_accessible :group_name, :position, :visible, :info_url
  attr_accessible :competitor_free_options, :noncompetitor_free_options
  attr_accessible :competitor_required, :noncompetitor_required

  validates :group_name, :presence => true
  validates :visible, :competitor_required, :noncompetitor_required, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :expense_items,:order => "expense_items.position"

  translates :group_name
  accepts_nested_attributes_for :translations
  attr_accessible :translations_attributes

  def self.free_options
    ["None Free", "One Free In Group", "One Free of Each In Group"]
  end

  validates :competitor_free_options, :inclusion => { :in => self.free_options, :allow_blank => true }
  validates :noncompetitor_free_options, :inclusion => { :in => self.free_options, :allow_blank => true }

  default_scope order('position ASC')
  scope :visible, where(:visible => true)

  after_initialize :init

  def init
    self.competitor_required = false if self.competitor_required.nil?
    self.noncompetitor_required = false if self.competitor_required.nil?
  end


  def to_s
    group_name
  end
end
