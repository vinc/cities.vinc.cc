class CitiesController < ApplicationController
  respond_to(:json, :html)

  expose(:cities)
  expose(:city)
  expose(:page) { (params[:page] || '1').to_i }

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
    self.cities = self.cities.where(name: query).desc(:population).page(page)
    self.results = self.cities.map { |city| { city: city } }
    respond_with(self.results)
  end

  def search
    m0, m1, s0 = mnt_dis_max, mnt_ele_min, sea_dis_max

    res = City
      .where(
        is_largest: true,
        population: pop_min..pop_max,
        seaports_cache: { '$elemMatch' => {
          :distance.lt => s0 * 1000 }
        },
        mountains_cache: { '$elemMatch' => {
          :distance.lt => m0 * 1000,
          :elevation.gt => m1 }
        })
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
      end.reverse

    # FIXME
    self.cities = Kaminari.paginate_array(res.map { |h| h[:city] }).page(page)
    self.results = Kaminari.paginate_array(res).page(page)

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
