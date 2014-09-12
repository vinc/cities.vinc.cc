class CitySerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :path, :title, :name, :country, :population, :elevation, :location

  has_many :mountains, :seaports

  def id
    object.id.to_s
  end

  def path
    city_path(object)
  end

  def country
    object.name
  end
end
