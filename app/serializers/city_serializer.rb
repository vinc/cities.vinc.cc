class CitySerializer < ActiveModel::Serializer
  attributes :id, :name, :country, :population, :elevation, :latitude, :longitude

  def id
    object.id.to_s
  end

  def longitude
    object.location[:coordinates][0]
  end

  def latitude
    object.location[:coordinates][1]
  end
end
