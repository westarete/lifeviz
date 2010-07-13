require 'progressbar'
require 'db/seed_methods'
include SeedMethods

class Species < Taxon
  ActiveRecord::Base.include_root_in_json = false
  validates_presence_of :parent_id, :on => :create, :message => "can't be blank"

  has_many :birth_weights , :dependent => :destroy, :foreign_key => :species_id
  has_many :adult_weights , :dependent => :destroy, :foreign_key => :species_id
  has_many :lifespans     , :dependent => :destroy, :foreign_key => :species_id
  has_many :litter_sizes  , :dependent => :destroy, :foreign_key => :species_id
  
  # after_create :move_to_genus # do we really need this? delete after the next rebuild if it wasn't needed
  
  def self.rebuild_stats
    species = Species.find_all_by_rank(6)
    progress "Building Stats", species.size do |progress_bar|
      species.each do |s|
        s.precalculate_stats
        progress_bar.inc
      end
    end
  end

  # Return the average adult weight in grams.
  def adult_weight_in_grams
    weights = adult_weights.collect(&:value_in_grams).delete_if{|x| x.nil? || x <= 0 } if adult_weights.any?
    weights && weights.any? ? ( weights.sum / weights.size.to_f ) : nil
  end

  # Return the average birth weight in grams.
  def birth_weight_in_grams
    weights = birth_weights.collect(&:value_in_grams).delete_if{|x| x.nil? || x <= 0 } if birth_weights.any?
    weights && weights.any? ? ( weights.sum / weights.size.to_f ) : nil
  end

  # Return the average lifespan in days.
  def lifespan_in_days
    lspans = lifespans.collect(&:value_in_days).delete_if{|x| x.nil? || x <= 0 } if lifespans.any?
    lspans && lspans.any? ? ( lspans.sum / lspans.size.to_f ) : nil
  end

  # Return the average litter size.
  def litter_size
    lsizes = litter_sizes.collect(&:measure).delete_if{|x| x.nil? || x <= 0 } if litter_sizes.any?
    lsizes && lsizes.any? ? ( lsizes.sum / lsizes.size.to_f ) : nil
  end

  def move_to_genus
    move_to_child_of(parent)
  end

  def precalculate_stats
    self.avg_lifespan      = self.lifespan_in_days
    self.avg_birth_weight  = self.birth_weight_in_grams
    self.avg_adult_weight  = self.adult_weight_in_grams
    self.avg_litter_size   = self.litter_size
    self.save
  end

  def validate
    unless self.parent_id && Taxon.find(self.parent_id) && Taxon.find(self.parent_id).rank == 5
      errors.add_to_base "Species needs to belong to a genus"
    end
  end

end

# == Schema Information
#
# Table name: taxa
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  parent_id        :integer
#  lft              :integer
#  rgt              :integer
#  rank             :integer
#  lineage_ids      :string(255)
#  avg_adult_weight :float
#  avg_birth_weight :float
#  avg_lifespan     :float
#  avg_litter_size  :float
#