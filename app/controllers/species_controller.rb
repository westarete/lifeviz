class SpeciesController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    if params[:taxon_id]
      @taxon = Taxon.find(params[:taxon_id])
    else
      @taxon = Taxon.root
    end
    @rank = @taxon.rank
    @species = @taxon.paginated_sorted_species(params[:page])
  end
  
  def data
    @taxon = Taxon.find(params[:taxon_id])
    @species = @taxon.paginated_sorted_species(params[:page])
    render :partial => "table", :layout => false
  end

  def new
    @species = Taxon.new
  end

  def create
    @species = Taxon.new(params[:species])
    if @species.save
      flash[:success] = "Species saved."
      redirect_to species_path(:id => @species.id)
    else
      flash[:failure] = "Species failed to save."
      render :new
    end
  end

  def show
    @species = Taxon.find(params[:id])
  end

  def edit
    @species = Taxon.find(params[:id])
  end

  def update
    @species = Taxon.find(params[:id])
    if @species.update_attributes(params[:species])
      flash[:success] = "Species updated."
      redirect_to species_path(:id => @species.id)
    else
      flash[:failure] = "Species failed to update."
      render :update
    end
  end

end
