class ItemController < ApplicationController
  # GET /item/ABCDEFG
  def index
    @item = ecs_item_lookup(:asin => params[:asin])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

end