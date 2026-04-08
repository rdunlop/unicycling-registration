class Avo::Resources::PaymentDetail < Avo::BaseResource
  self.model_class = ::PaymentDetail
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("details ILIKE :q OR line_item_type ILIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :line_item_type, as: :text
    field :details, as: :text
    field :amount_cents, as: :number
    field :free, as: :boolean
    field :refunded, as: :boolean
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
