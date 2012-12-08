class ExpenseItem < ActiveRecord::Base
  attr_accessible :cost, :description, :export_name, :name, :position

  validates :name, :presence => true
  validates :description, :presence => true
  validates :position, :presence => true
  validates :cost, :presence => true
end
