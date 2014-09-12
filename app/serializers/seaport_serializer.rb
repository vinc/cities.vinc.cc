class SeaportSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :path, :title, :name, :country, :location, :distance

  def id
    object.id.to_s
  end

  def path
    '/' # seaport_path(object)
  end

  def country
    object.name
  end
end
