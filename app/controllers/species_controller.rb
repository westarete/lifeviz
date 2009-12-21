class OrganismController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    @organisms = Organism.all
  end
  
  def data
    @taxon = Taxon.find(params[:taxon])
    @organisms = @taxon.organisms
    render :partial => "table"
  end

  def new
    @organism = Organism.new
  end

  def create
    @organism = Organism.new(params[:organism])
    if @organism.save
      flash[:success] = "Organism saved."
      redirect_to organism_path(:id => @organism.id)
    else
      flash[:failure] = "Organism failed to save."
      render :new
    end
  end

  def show
    @organism = Organism.find(params[:id])
  end

  def edit
    @organism = Organism.find(params[:id])
  end

  def update
    @organism = Organism.find(params[:id])
    if @organism.update_attributes(params[:organism])
      flash[:success] = "Organism updated."
      redirect_to organism_path(:id => @organism.id)
    else
      flash[:failure] = "Organism failed to update."
      render :update
    end
  end

end
