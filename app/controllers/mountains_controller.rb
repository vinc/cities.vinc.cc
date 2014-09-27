class MountainsController < ApplicationController
  respond_to(:json, :html)

  expose(:mountain)
  expose(:mountains)
  expose(:cities) { [] }
  expose(:page) { (params[:page] || '1').to_i }

  def index
    self.mountains = Mountain.desc(:elevation).page(page)
    respond_with(self.mountains)
  end

  def show
    self.mountains = [mountain]
    respond_with(mountain)
  end
end
