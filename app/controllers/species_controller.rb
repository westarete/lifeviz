class SpeciesController < ApplicationController
  before_filter :load_taxonomy
  
  def new
    @species = Species.new
  end

  def create
  end

  def edit
    @species = Species.find(params[:id])
  end

  def update
  end

  def show
  end

end
