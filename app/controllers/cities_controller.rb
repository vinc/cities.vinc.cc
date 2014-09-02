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

  def best
    cities = City
      .where(:population.lt => 500000)
      .where(:population.gt => 200000)
      .desc(:population)
      .limit(2000)

    cities = cities.delete_if do |city| # Mongoid::Criteria to Array
      City
        .where(:population.gt => city.population)
        .geo_near(city.location).max_distance(100 * 1000).spherical
        .count > 0
    end

    scope = cities.map do |city|
      mountains = Mountain
        .where(:elevation.gt => 2500)
        .geo_near(city.location).max_distance(500 * 1000).spherical

      seaports = Seaport
        .geo_near(city.location).max_distance(10 * 1000).spherical

      {
        city: city,
        mountains: mountains,
        seaports: seaports
      }
    end.sort_by do |city|
      a = city[:mountains].count
      b = city[:seaports].count
      a == 0 || b == 0 ? 0 : a + b
    end.last(20).reverse

    respond_with(scope)
  end
end
