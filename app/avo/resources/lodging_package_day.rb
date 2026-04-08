class Avo::Resources::LodgingPackageDay < Avo::BaseResource
  self.model_class = ::LodgingPackageDay
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("id::text = ?", params[:q]) }
  }

  def fields
    field :id, as: :id
    field :created_at, as: :date_time
  end
end
