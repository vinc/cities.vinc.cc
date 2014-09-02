class CitiesController < ApplicationController
  respond_to(:json)

  expose(:cities)
  expose(:city)

  def index
    query = Regexp.new(Regexp.escape(params[:name]), Regexp::IGNORECASE)
    scope = cities.desc(:population).limit(20)
    scope = scope.where(name: query) if params[:name]
    respond_with(scope)
  end
end
