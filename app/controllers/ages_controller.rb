class AgesController < ApplicationController
  before_filter :find_species
  
  def new
    @age = Age.new
  end
  
  def edit
    @age = Age.new
  end
  
  private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
