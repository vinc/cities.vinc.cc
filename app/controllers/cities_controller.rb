class CitiesController < ApplicationController
  respond_to(:json, :html)

  expose(:cities)
  expose(:city)
  expose(:limit) { (params[:limit] || '1000').to_i }

  expose(:search) { params[:search] || {} }
  expose(:name) { search[:name] || '' }
  expose(:pop_max) { (search[:pop_max] || '500000').to_i }
  expose(:pop_min) { (search[:pop_min] || '200000').to_i }
  expose(:mnt_ele_min) { (search[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (search[:mnt_dis_max] || '500').to_i }
  expose(:sea_dis_max) { (search[:sea_dis_max] || '10').to_i }

  expose(:results) { [] }

  def index
    query = Regexp.new(Regexp.escape(name), Regexp::IGNORECASE)
    self.cities = self.cities.where(name: query).desc(:population).limit(limit)
    self.results = self.cities.map { |city| { city: city } }
    respond_with(self.results)
  end

  def best
    self.results = City
      .where(:population.lt => pop_max)
      .where(:population.gt => pop_min)
      .desc(:population)
      .limit(1000)

    self.results = self.results.delete_if do |city| # Mongoid::Criteria to Array
      City
        .where(:population.gt => city.population)
        .geo_near(city.location).max_distance(50 * 1000).spherical
        .count > 0
    end

    self.results = self.results.map do |city|
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
    end.keep_if do |city|
      city[:mountains].count > 2 && city[:seaports].count > 0
    end.sort_by do |city|
      city[:mountains].count + city[:seaports].count
    end.last(limit).reverse

    self.cities = self.results.map { |hash| hash[:city] }

    respond_with(self.results)
  end

  def show
    self.results = [{ city: city }]

    respond_with(city)
  end

  def welcome
  end
end
