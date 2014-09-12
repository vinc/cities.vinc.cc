class CitiesController < ApplicationController
  respond_to(:json, :html)

  expose(:cities)
  expose(:city)
  expose(:page) { (params[:page] || '1').to_i }

  expose(:query) { params[:query] || {} }
  expose(:name) { query[:name] || '' }
  expose(:pop_max) { (query[:pop_max] || '500000').to_i }
  expose(:pop_min) { (query[:pop_min] || '200000').to_i }
  expose(:tmp_min_min) { (query[:tmp_min_min] || '10').to_i }
  expose(:tmp_max_max) { (query[:tmp_max_max] || '30').to_i }
  expose(:mnt_ele_min) { (query[:mnt_ele_min] || '2500').to_i }
  expose(:mnt_dis_max) { (query[:mnt_dis_max] || '500').to_i }
  expose(:sea_dis_max) { (query[:sea_dis_max] || '20').to_i }

  def index
    query = Regexp.new(Regexp.escape(name), Regexp::IGNORECASE)
    self.cities = cities.where(name: query).desc(:population).page(page)
    respond_with(self.cities)
  end

  def search
    m0, m1, s0 = mnt_dis_max, mnt_ele_min, sea_dis_max

    self.cities = City
      .where(is_largest: true, population: pop_min..pop_max)
      .elem_match(min_temperatures: {
        '$lt' => tmp_min_min
      })
      .not.elem_match(max_temperatures: {
        '$gt' => tmp_max_max
      })
      .elem_match(seaports_cache: {
        :distance.lt => s0 * 1000
      })
      .elem_match(mountains_cache: {
        :distance.lt => m0 * 1000,
        :elevation.gt => m1
      })
      .keep_if do |city|
        city[:seaports_count] =
          city.find_seaports(max_distance: s0).count
        city[:mountains_count] =
          city.find_mountains(max_distance: m0, min_elevation: m1).count
        city[:seaports_count] > 0 && city[:mountains_count] > 2
      end.sort_by do |city|
        city[:seaports_count] + city[:mountains_count]
      end.reverse

    self.cities = Kaminari.paginate_array(self.cities).page(page)

    respond_with(self.cities)
  end

  def show
    self.cities = [city] # Needed for map
    respond_with(city)
  end

  def welcome
    self.cities = [] # Needed for map
  end
end
