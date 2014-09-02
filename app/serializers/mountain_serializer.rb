class MountainSerializer < ActiveModel::Serializer
  attributes :id, :name, :elevation, :latitude, :longitude, :distance

  def id
    object.id.to_s
  end

  def longitude
    object.location[:coordinates][0]
  end

  def latitude
    object.location[:coordinates][1]
  end

  def distance
    object.geo_near_distance
  end
end
