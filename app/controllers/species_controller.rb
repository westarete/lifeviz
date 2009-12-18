class SpeciesController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    @species = Species.all
  end
  
  def data
    @species = Species.all
    render :partial => "table"
  end

  def new
    @species = Species.new
  end

  def create
    @species = Species.new(params[:species])
    if @species.save
      flash[:success] = "Species saved."
      redirect_to species_path(:id => @species.id)
    else
      flash[:failure] = "Species failed to save."
      render :new
    end
  end

  def show
    @species = Species.find(params[:id])
  end

  def edit
    @species = Species.find(params[:id])
  end

  def update
    @species = Species.find(params[:id])
    if @species.update_attributes(params[:species])
      flash[:success] = "Species updated."
      redirect_to species_path(:id => @species.id)
    else
      flash[:failure] = "Species failed to update."
      render :update
    end
  end

end
