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
  
  has_one :age, :dependant => :destroy
  
  def validate
    @parent = Taxon.find(self.parent_id)
    if @parent.rank != 5
      errors.add_to_base "Species need to belong to a genus"
    end
  end
  
  def save_under_parent(parent)
    Species.transaction do
      save
      move_to_child_of(parent)
    end
  end
  
end
