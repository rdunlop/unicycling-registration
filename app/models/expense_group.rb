class ExpenseGroup < ActiveRecord::Base
  attr_accessible :group_name, :position, :visible

  validates :group_name, :presence => true
  validates :visible, :inclusion => { :in => [true, false] } # because it's a boolean
end
