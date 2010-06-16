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
  
  # Get the mode of the lifespans' units, and the average of the lifespan values, and return it in a string
  def lifespan_with_units
    if lifespans.any?
      case lifespans.group_by(&:units).values.max_by(&:size).first.units
      when "Days"
        "%.2f Days" % lifespan_in_days
      when "Months"
        "%.2f Months" % (lifespan_in_days / 30.0)
      when "Years"
        "%.2f Years" % (lifespan_in_days / 365.0)
      end
    else
      "N/A"
    end
  end
  
  # Return the average lifespan in days.
  def lifespan_in_days
    if lifespans.any?
      lifespans.collect(&:value_in_days).sum / lifespans.length.to_f
    else
      0.0
    end
  end
  
end
