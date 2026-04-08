class Avo::Resources::LodgingPackage < Avo::BaseResource
  self.model_class = ::LodgingPackage
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("id::text = ?", params[:q]) }
  }

  def fields
    field :id, as: :id
    field :total_cost_cents, as: :number
    field :created_at, as: :date_time
  end
end
