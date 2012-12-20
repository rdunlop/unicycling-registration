class ExpenseGroup < ActiveRecord::Base
  attr_accessible :group_name, :position, :visible

  validates :group_name, :presence => true
  validates :visible, :inclusion => { :in => [true, false] } # because it's a boolean

  has_many :expense_items,:order => "expense_items.position"

  scope :visible, where(:visible => true)

  def to_s
    group_name
  end
end
