class TagsController < ApplicationController
  def index
    render "index", :locals => {:items => Tag.all}
  end

  def show
    render "show", :locals => {:item => Tag.find(params[:id])}
  end
end
