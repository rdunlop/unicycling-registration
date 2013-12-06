class Payment < ActiveRecord::Base
  scope :completed, where(:completed => true)

  validates :user_id, :presence => true
  validate :transaction_id_or_note
  validates_associated :payment_details

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
      if pd.details.nil? or pd.details.empty?
        target_details = nil
      else
        target_details = pd.details
      end

      rei = RegistrantExpenseItem.where({:registrant_id => pd.registrant.id, :expense_item_id => pd.expense_item.id, :free => pd.free, :details => target_details}).first
      unless rei.nil?
        rei.destroy
      end
    end
  end

  # return a set of payment_details which are unique With-respect-to {amount, expense_item }
  def unique_payment_details
    results = []
    payment_details.each do |pd|
      res = nil
      results.each do |r|
        if r.expense_item_id == pd.expense_item_id and r.amount == pd.amount
          res = r
          break
        end
      end

      if res.nil?
        results << PaymentDetailSummary.new({:expense_item_id => pd.expense_item_id, :count => 1, :amount => pd.amount})
      else
        res.count += 1
      end
    end
    results
  end

  def paypal_post_url
    EventConfiguration.paypal_base_url + "/cgi-bin/webscr"
  end

  def total_amount
    payment_details.reduce(0) { |memo, pd| memo + pd.cost }.to_f
  end

  def self.total_received
    total = 0
    Payment.includes(:payment_details).completed.each do |payment|
      total += payment.total_amount
    end
    total
  end

  def self.paid_details
    all = []
    Registrant.all.each do |reg|
      all += reg.paid_details
    end
    all
  end

  def self.paid_expense_items
    all = []
    Registrant.includes(:payment_details => [:expense_item]).all.each do |reg|
      all += reg.paid_expense_items
    end
    all
  end
end
