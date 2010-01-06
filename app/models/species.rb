class Species < Taxon
  
  def save_under_parent(parent)
    Species.transaction do
      save
      move_to_child_of(parent)
    end
  end
  
end
