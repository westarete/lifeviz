# == Schema Information
#
# Table name: taxa
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  rank        :integer
#  lineage_ids :string(255)
#

class Species < Taxon
  validates_presence_of :parent_id, :on => :create, :message => "can't be blank"
  
  has_many :lifespans, :dependent => :destroy, :foreign_key => :species_id
  
  # Hack because Rails wants to create my associated models for me, and I
  # don't want it to because it doesn't work!!
  def lifespan=(lifespanhash)
    nil
  end
  
  after_save :move_to_genus

  def validate
    unless self.parent_id && Taxon.find(self.parent_id) && Taxon.find(self.parent_id).rank == 5
      errors.add_to_base "Species needs to belong to a genus"
    end
  end
  
  def move_to_genus
    move_to_child_of(parent)
  end
  
end
