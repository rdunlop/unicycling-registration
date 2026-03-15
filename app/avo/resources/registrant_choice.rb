class Avo::Resources::RegistrantChoice < Avo::BaseResource
  self.model_class = ::RegistrantChoice
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("value ILIKE ?", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :value, as: :text
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
