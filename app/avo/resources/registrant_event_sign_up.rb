class Avo::Resources::RegistrantEventSignUp < Avo::BaseResource
  self.model_class = ::RegistrantEventSignUp
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("id::text = ?", params[:q]) }
  }

  def fields
    field :id, as: :id
    field :signed_up, as: :boolean
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
