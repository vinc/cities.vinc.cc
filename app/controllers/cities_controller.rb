class CitiesController < ApplicationController
  respond_to(:json)

  expose(:cities)
  expose(:city)

  def index
    respond_with(cities.desc(:population).limit(20))
  end
end
