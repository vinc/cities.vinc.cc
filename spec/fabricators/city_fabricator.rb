Fabricator(:city) do
  name { Faker::Address.city }
  country { I18nData.country_code(Faker::Address.country) }
  population { Random.new.rand(0..1000000) }
  location do
    {
      type: 'Point',
      coordinates: [
        Faker::Address.longitude.to_f,
        Faker::Address.latitude.to_f
      ]
    }
  end
end
