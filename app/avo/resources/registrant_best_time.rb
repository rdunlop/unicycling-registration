class Avo::Resources::RegistrantBestTime < Avo::BaseResource
  self.model_class = ::RegistrantBestTime
  self.title = :id
  self.includes = []
  self.search = {
    query: -> { query.where("value ILIKE :q OR source_location ILIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :value, as: :text
    field :source_location, as: :text
    field :created_at, as: :date_time
    field :versions, as: :has_many, resource: "Avo::Resources::Version"
  end
end
