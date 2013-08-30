class RegistrantExpenseItem < ActiveRecord::Base
  attr_accessible :expense_item_id, :registrant_id, :details, :free

  belongs_to :registrant
  belongs_to :expense_item, :inverse_of => :registrant_expense_items

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  validates :expense_item, :registrant, :presence => true
  validates_associated :registrant

end
