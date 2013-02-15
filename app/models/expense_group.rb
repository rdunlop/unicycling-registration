class ExpenseGroup < ActiveRecord::Base
  attr_accessible :group_name, :position, :visible, :info_url

  validates :group_name, :presence => true
  validates :visible, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :expense_items,:order => "expense_items.position"

  default_scope order('position ASC')
  scope :visible, where(:visible => true)

  def to_s
    group_name
  end
end
