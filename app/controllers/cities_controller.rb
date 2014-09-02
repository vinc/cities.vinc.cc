class CitiesController < ApplicationController
  respond_to(:json)

  expose(:cities)
  expose(:city)

  def index
    scope = cities.desc(:population).limit(20)
    scope = scope.where(name: params[:name]) if params[:name]
    respond_with(scope)
  end
end
