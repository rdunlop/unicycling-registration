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

  def paypal_url(return_url, notify_url)
    # Reference: https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_html_Appx_websitestandard_htmlvariables
    #
    values = {
      :business => ENV['PAYPAL_ACCOUNT'],
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => id,
      :notify_url => notify_url,
      :no_shipping => 2, # I require a shipping address?
      :currency_code => "USD",
      :cancel_return => return_url
    }
    payment_details.each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => item.amount,
        "item_name_#{index+1}" => item.expense_item.to_s,
        "quantity_#{index+1}" => 1
      })
    end
    PAYPAL_BASE_URL + "/cgi-bin/webscr?" + values.to_query
  end
end
