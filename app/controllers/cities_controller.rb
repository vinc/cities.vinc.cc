class CitiesController < ApplicationController
  respond_to(:json)

  expose(:cities)
  expose(:city)
  expose(:limit) { (params[:limit] || '20').to_i }
  expose(:pop_max) { (params[:pop_max] || '500000').to_i }
  expose(:pop_min) { (params[:pop_min] || '200000').to_i }
  expose(:mnt_ele_min) { (params[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (params[:mnt_dis_max] || '500').to_i }
  expose(:sea_dis_max) { (params[:sea_dis_max] || '10').to_i }

  def index
    query = Regexp.new(Regexp.escape(params[:name]), Regexp::IGNORECASE)
    scope = cities.desc(:population).limit(limit)
    scope = scope.where(name: query) if params[:name]
    respond_with(scope)
  end

  def best
    cities = City
      .where(:population.lt => pop_max)
      .where(:population.gt => pop_min)
      .desc(:population)
      .limit(1000)

    cities = cities.delete_if do |city| # Mongoid::Criteria to Array
      City
        .where(:population.gt => city.population)
        .geo_near(city.location).max_distance(50 * 1000).spherical
        .count > 0
    end

    scope = cities.map do |city|
      mountains = Mountain
        .where(:elevation.gt => mnt_ele_min)
        .geo_near(city.location).max_distance(mnt_dis_max * 1000).spherical

      seaports = Seaport
        .geo_near(city.location).max_distance(sea_dis_max * 1000).spherical

      {
        city: city,
        mountains: mountains,
        seaports: seaports
      }
    end.sort_by do |city|
      a = city[:mountains].count
      b = city[:seaports].count
      a > 2 && b > 0 ? a + b : 0
    end.last(limit).reverse

    respond_with(scope)
  end
end
