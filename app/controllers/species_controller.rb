class SpeciesController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    if params[:taxon]
      if ! @taxon = Taxon.find_by_name(params[:taxon].capitalize)
        @taxon = Taxon.root
        @disable_remaining_dropdowns = "disabled"
        flash.now[:notice] = "#{params[:rank].capitalize} #{params[:taxon].capitalize} could not be found."
      else
        @disable_remaining_dropdowns = false
      end
    else
      @taxon = Taxon.root
      @disable_remaining_dropdowns = "disabled"
    end
    @rank = @taxon.rank
    @species = @taxon.paginated_sorted_species(params[:page])
  end
  
  def data
    if params[:taxon_id] && ! params[:taxon_id].blank?
      @taxon = Taxon.find(params[:taxon_id])
    else
      @taxon = Taxon.find(1)
    end
    respond_to do |format|
      format.html do
        @species = @taxon.paginated_sorted_species(params[:page])
        render :partial => "table", :layout => false
      end
      format.json do
        render :json => @taxon.complete_species.to_json(
          :only => :name,
          :methods => [
            :lifespan_in_days,
            :birth_weight_in_grams,
            :adult_weight_in_grams,
            :litter_size
          ]
        )
      end
    end
  end

  def new
    @species = Species.new
    @taxon = Taxon.root
  end

  def create
    @taxon = Taxon.root
    if params[:genus]
      @genus = Taxon.find(params[:genus])
      @species = Species.new(params[:species])
      @species.rank = 6
      @species.parent_id = @genus.id
      if @species.save
        flash[:success] = "Species saved."
        redirect_to species_path(:id => @species.id)
      else
        flash.now[:failure] = "Species failed to save."
        render :new
      end
    else
      flash.now[:failure] = "You need to select a genus."
      render :new
    end
  end

  def show
    @species = Species.find(params[:id])
  end

  def edit
    @species = Species.find(params[:id])
    @age = @species.age ? @species.age : @species.build.age
  end

  def update
    @species = Species.find(params[:id])
    @age = Age.find_or_create_by_taxon_id(params[:id])
    if Species.transaction {
        @species.update_attributes(params[:species])
        @age.update_attributes(params[:species][:age])
    } then
      flash[:success] = "Species updated."
      redirect_to species_path(:id => @species.id)
    else
      flash.now[:failure] = "Species failed to update."
      render :update
    end
  end

end
