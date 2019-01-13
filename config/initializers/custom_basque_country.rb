# Create a custom basque country
ISO3166::Data.register(
  alpha2: 'EU',
  address_format: "
    {{recipient}}
    {{street}}
    {{postalcode}} {{city}}
    {{region}}
    {{country}}",
  name: 'Basque Country',
  languages_official: %w(es),
  postal_code: true,
  subdivisions: {
    A: {
      name: 'Álava'
    },
    B: {
      name: 'Biscay',
    },
    G: {
      name: 'Gipuzkoa'
    }
  }
)
