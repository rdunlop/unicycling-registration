class Avo::Resources::Competition < Avo::BaseResource
  self.model_class = ::Competition
  self.title = :name
  self.includes = []
  self.search = {
    query: -> { query.where("name ILIKE ?", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :scoring_class, as: :text
    field :awarded, as: :boolean
    field :created_at, as: :date_time
  end
end
