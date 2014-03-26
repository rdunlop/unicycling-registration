class RefundPresenter
  # this is an admin payment
  #
  # references
  # http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
  # http://stackoverflow.com/questions/972857/multiple-objects-in-a-rails-form
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attribute :note, String
  attribute :percentage, Integer

  attribute :user, User
  attribute :saved_refund, Refund

  def add_registrant(registrant)
    registrant.paid_details.each do |pd|
      @existing_payment_details << RefundDetailPresenter.new(:payment_detail_id => pd.id)
    end
  end

  def initialize(params = {})
    self.percentage = 100
    @existing_payment_details = []
    params.each do |name, value|
      send("#{name}=", value)
    end
  end

  class RefundDetailPresenter
    include Virtus.model

    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :payment_detail_id, Integer
    attribute :refund, Boolean

    validates :payment_detail_id, :presence => true

    def initialize(params = {})
      params.each do |name, value|
        send("#{name}=", value)
      end
    end

    def payment_detail
      PaymentDetail.find(payment_detail_id)
    end

    def persisted?
      false
    end
  end

  def paid_details
    @existing_payment_details
  end

  def paid_details_attributes=(params = {})
    params.values.each do |detail|
      @existing_payment_details << RefundDetailPresenter.new(detail)
    end
  end

  def registrants
    regs = paid_details.map {|nd| nd.payment_detail.registrant}
    (regs).uniq
  end

  def persisted?
    false
  end

  # delegate to the underlying payment
  def errors
    @errors || []
  end

  def errors=(err)
    @errors = err
  end

  # validate based on the undelying payment validation
  def valid?
    r = self.build_refund
    self.errors = r.errors.clone
    r.valid?
  end

  def build_refund
    refund = Refund.new
    refund.note = self.note
    refund.percentage = self.percentage

    self.paid_details.each do |pd|
      if pd.refund
        detail = refund.refund_details.build()
        detail.payment_detail_id = pd.payment_detail_id
      end
    end
    refund.refund_date = DateTime.now
    refund.user = self.user
    return refund
  end

  def save
    # XXX any way to have this automatically call valid? (instead of me having to do so?)
    refund = self.build_refund
    self.valid?
    return false unless refund.valid?
    self.saved_refund = refund
    refund.save
  end
end
