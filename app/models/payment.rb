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
    return true unless self.completed_changed?

    payment_details.each do |pd|
      rei = RegistrantExpenseItem.where({:registrant_id => pd.registrant.id, :expense_item_id => pd.expense_item.id}).first
      unless rei.nil?
        rei.destroy
      end
    end
  end

  def paypal_post_url
    PAYPAL_BASE_URL + "/cgi-bin/webscr"
  end

  def total_amount
    payment_details.reduce(0) { |memo, pd| memo + pd.amount }
  end

  def self.total_received
    total = 0
    Payment.all.each do |payment|
      next unless payment.completed

      total += payment.total_amount
    end
    total
  end
end
