class Avo::Resources::Event < Avo::BaseResource
  self.model_class = ::Event
  self.title = :name
  self.includes = []
  self.search = {
    query: -> { query.with_translations.where("event_translations.name ILIKE ?", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :artistic, as: :boolean
    field :standard_skill, as: :boolean
    field :visible, as: :boolean
    field :created_at, as: :date_time
  end
end
