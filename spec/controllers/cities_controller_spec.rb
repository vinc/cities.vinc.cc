require 'rails_helper'

RSpec.describe CitiesController do

  describe 'GET index' do
    let!(:cities) do
      Fabricate.times(5, :city).sort_by(&:population).reverse
    end

    before do
      City.import(force: true)
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'exposes cities' do
      get :index
      sleep(1) # FIXME: Remove sleep
      expect(controller.cities.to_a).to eq(cities) # FIXME: Remove to_a
    end
  end

  describe 'GET show' do
    let!(:city) { Fabricate(:city) }

    it 'returns http success' do
      get :show, id: city.id
      expect(response).to have_http_status(:success)
    end

    it 'exposes city' do
      get :show, id: city.id
      expect(controller.city).to eq(city)
    end
  end

end
