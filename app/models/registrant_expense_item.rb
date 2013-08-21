class RegistrantExpenseItem < ActiveRecord::Base
  attr_accessible :expense_item_id, :registrant_id, :details

  belongs_to :registrant
  belongs_to :expense_item

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  validates :expense_item, :registrant, :presence => true

  validate :no_more_than_the_maximum_number

  def no_more_than_the_maximum_number
    if new_record?
      unless expense_item.nil?
        if expense_item.maximum_reached?
          max = expense_item.maximum_available
          errors[:base] << "Unable to Have more than #{max} #{expense_item.to_s}"
        end
      end
    end
  end
end
