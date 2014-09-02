class MountainsController < ApplicationController
  respond_to(:json)

  expose(:city)
  expose(:distance) do
    (params[:distance] || '1000').to_i * 1000
  end
  expose(:mountains) do
    Mountain.geo_near(city.location).max_distance(distance).spherical
  end

  def index
    respond_with(mountains)
  end
end
