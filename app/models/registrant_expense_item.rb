class RegistrantExpenseItem < ActiveRecord::Base
  attr_accessible :expense_item_id, :registrant_id

  belongs_to :registrant
  belongs_to :expense_item

  validates :expense_item, :presence => true
  validates :registrant, :presence => true


  def paid_for?
    @reg_items_paid_for = registrant.payment_details
    @reg_items_paid_for.each do |ri|
      if ri.expense_item == expense_item
        return true
      end
    end
    false
  end
end
