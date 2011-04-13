class PagesController < ApplicationController
  before_filter :set_title

  def show
    render params[:id]
  end

  private
  
  def set_title
    @title = params[:id].titleize rescue nil
  end
end