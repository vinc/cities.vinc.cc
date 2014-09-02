class MountainsController < ApplicationController
  respond_to(:json)

  expose(:city)
  expose(:mountains) do
    #Mountain.geo_near(city.location[:coordinates]).spherical
    #Mountain.geo_near(city.location[:coordinates]).max_distance(500).spherical
    Mountain.geo_near(city.location).max_distance(1000000).spherical
  end

  def index
    respond_with(mountains)
  end
end
