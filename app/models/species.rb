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

  has_many :birth_weights , :dependent => :destroy, :foreign_key => :species_id
  has_many :adult_weights , :dependent => :destroy, :foreign_key => :species_id
  has_many :lifespans     , :dependent => :destroy, :foreign_key => :species_id
  has_many :litter_sizes  , :dependent => :destroy, :foreign_key => :species_id
  
  after_save :move_to_genus

  def validate
    unless self.parent_id && Taxon.find(self.parent_id) && Taxon.find(self.parent_id).rank == 5
      errors.add_to_base "Species needs to belong to a genus"
    end
  end
  
  def move_to_genus
    move_to_child_of(parent)
  end
  
  def lifespan
    if lifespans.any?
      case lifespans.group_by(&:units).values.max_by(&:size).first.units
      when "Days"
        (lifespans.collect(&:value_in_days).sum / lifespans.length.to_f).to_s + " Days"
      when "Months"
        ((lifespans.collect(&:value_in_days).sum / lifespans.length.to_f) / 30.0).to_s + " Months"
      when "Years"
        ((lifespans.collect(&:value_in_days).sum / lifespans.length.to_f) / 365.0).to_s + " Years"
      end
    else
      "N/A"
    end
  end
  
end
