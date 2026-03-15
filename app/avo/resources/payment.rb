class Avo::Resources::Payment < Avo::BaseResource
  self.model_class = ::Payment
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("transaction_id ILIKE :q OR invoice_id ILIKE :q OR id::text = :id", q: "%#{params[:q]}%", id: params[:q]) }
  }

  def fields
    field :id, as: :id
    field :completed, as: :boolean
    field :transaction_id, as: :text
    field :invoice_id, as: :text
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
