class ExpenseGroup < ActiveRecord::Base
  attr_accessible :group_name, :position, :visible, :info_url
  attr_accessible :competitor_free_options, :noncompetitor_free_options

  validates :group_name, :presence => true
  validates :visible, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :expense_items,:order => "expense_items.position"

  def self.free_options
    ["None Free", "One Free In Group", "One Free of each In Group"]
  end

  validates :competitor_free_options, :inclusion => { :in => self.free_options, :allow_blank => true }
  validates :noncompetitor_free_options, :inclusion => { :in => self.free_options, :allow_blank => true }

  default_scope order('position ASC')
  scope :visible, where(:visible => true)


  def to_s
    group_name
  end
end
