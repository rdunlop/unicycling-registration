class Payment < ActiveRecord::Base
  attr_accessible :cancelled, :completed, :completed_date, :payment_date, :transaction_id, :user_id, :note
  attr_accessible :payment_details_attributes

  scope :completed, where(:completed => true)

  validates :user_id, :presence => true
  validate :transaction_id_or_note

  has_paper_trail

  belongs_to :user
  has_many :payment_details, :inverse_of => :payment, :dependent => :destroy
  accepts_nested_attributes_for :payment_details, :reject_if => proc { |attributes| attributes['registrant_id'].blank? }

  after_save :update_registrant_items
  after_initialize :init

  def init
    self.cancelled = false if self.cancelled.nil?
    self.completed = false if self.completed.nil?
  end

  def transaction_id_or_note
    if completed
      if transaction_id.blank? and note.blank?
        errors[:base] << "Transaction ID or Note must be filled in"
      end
    end
  end

  def update_registrant_items
    return true unless self.completed == true
    return true unless self.completed_changed?

    payment_details.each do |pd|
      rei = RegistrantExpenseItem.where({:registrant_id => pd.registrant.id, :expense_item_id => pd.expense_item.id, :free => pd.free}).first
      unless rei.nil?
        rei.destroy
      end
    end
  end

  def paypal_post_url
    EventConfiguration.paypal_base_url + "/cgi-bin/webscr"
  end

  def total_amount
    payment_details.reduce(0) { |memo, pd| memo + pd.amount }
  end

  def self.total_received
    total = 0
    Payment.includes(:payment_details).each do |payment|
      next unless payment.completed

      total += payment.total_amount
    end
    total
  end

  def self.paid_expense_items
    all = []
    Payment.all.each do |payment|
      next unless payment.completed

      all += payment.payment_details.map{ |ei| ei.expense_item }
    end
    all
  end
end
