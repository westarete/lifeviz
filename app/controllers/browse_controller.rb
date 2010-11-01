class BrowseController < ApplicationController
  layout 'browse'
  def index
    @kingdoms = Taxon.kingdoms
  end
end
