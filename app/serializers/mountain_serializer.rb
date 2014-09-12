class MountainSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :path, :title, :name, :elevation, :location, :distance

  def id
    object.id.to_s
  end

  def path
    '/' # mountain_path(object)
  end
end
