class CitiesController < ApplicationController
  respond_to(:json, :html)

  expose(:cities)
  expose(:city)
  expose(:limit) { (params[:limit] || '1000').to_i }

  expose(:query) { params[:query] || {} }
  expose(:name) { query[:name] || '' }
  expose(:pop_max) { (query[:pop_max] || '500000').to_i }
  expose(:pop_min) { (query[:pop_min] || '200000').to_i }
  expose(:mnt_ele_min) { (query[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (query[:mnt_dis_max] || '500').to_i }
  expose(:sea_dis_max) { (query[:sea_dis_max] || '20').to_i }

  expose(:results) { [] }

  def index
    query = Regexp.new(Regexp.escape(name), Regexp::IGNORECASE)
    self.cities = self.cities.where(name: query).desc(:population).limit(limit)
    self.results = self.cities.map { |city| { city: city } }
    respond_with(self.results)
  end

  def search
    m0, m1, s0 = mnt_dis_max, mnt_ele_min, sea_dis_max

    self.results = City
      .where(population: pop_min..pop_max, is_largest: true)
      .where('this.seaports_cache.length > 0 && this.mountains_cache.length > 2')
      .map do |city|
        {
          city: city,
          seaports: city.find_seaports(max_distance: s0),
          mountains: city.find_mountains(max_distance: m0, min_elevation: m1)
        }
      end.keep_if do |city|
        city[:seaports].count > 0 && city[:mountains].count > 2
      end.sort_by do |city|
        city[:seaports].count + city[:mountains].count
      end.last(limit).reverse

    self.cities = self.results.map { |hash| hash[:city] }

    respond_with(self.results)
  end

  def show
    self.results = [{
      city: city,
      seaports: city.find_seaports,
      mountains: city.find_mountains
    }]

    respond_with(city)
  end

  def welcome
  end
end
