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
    @taxon = Taxon.root
  end

  def create
    @genus = Taxon.find(params[:genus])
    @species = Taxon.new(params[:species])
    @species.rank = 6
    if Taxon.transaction {@species.save; @species.move_to_child_of(@genus)}
      flash[:success] = "Species saved."
      redirect_to species_path(:id => @species.id)
    else
      flash.now[:failure] = "Species failed to save."
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
      flash.now[:failure] = "Species failed to update."
      render :update
    end
  end

end
