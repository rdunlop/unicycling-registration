class Payment < ActiveRecord::Base
  attr_accessible :cancelled, :completed, :completed_date, :transaction_id, :user_id
  attr_accessible :payment_details_attributes


  validates :user_id, :presence => true

  has_paper_trail

  belongs_to :user
  has_many :payment_details, :inverse_of => :payment, :dependent => :destroy
  accepts_nested_attributes_for :payment_details

  after_save :update_registrant_items
  after_initialize :init

  def init
    self.cancelled = false if self.cancelled.nil?
    self.completed = false if self.completed.nil?
  end

  def update_registrant_items
    return true unless self.completed == true

    payment_details.each do |pd|
      rei = RegistrantExpenseItem.where({:registrant_id => pd.registrant.id, :expense_item_id => pd.expense_item.id}).first
      unless rei.nil?
        rei.destroy
      end
    end
  end
end
