# Populates Prawn::Labels.types (required by the prawn-labels gem at
# PDF-render time) from the DB-backed SystemLabelType/CustomLabelType records.
module LabelTypeRegistry
  def self.load_into_prawn!
    system_types = SystemLabelType.all.index_by(&:name).transform_values(&:to_prawn_type_hash)
    custom_types = CustomLabelType.all.index_by(&:name).transform_values(&:to_prawn_type_hash)
    Prawn::Labels.types = system_types.merge(custom_types)
  end
end
