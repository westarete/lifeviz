class PagesController < ApplicationController
  before_filter :set_title
  # Probably a good idea to do page caching here

  def show
    render params[:id]
  end

  private
  
  def set_title
    @title = params[:id].titleize rescue nil
    @body_class = params[:id]
  end
end