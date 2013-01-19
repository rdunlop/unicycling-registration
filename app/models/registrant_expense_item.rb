class RegistrantExpenseItem < ActiveRecord::Base
  attr_accessible :expense_item_id, :registrant_id

  belongs_to :registrant
  belongs_to :expense_item

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  validates :expense_item, :presence => true
  validates :registrant, :presence => true

end
