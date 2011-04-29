require 'db/seed_methods'
include SeedMethods
require 'lib/monkeypatches'

class Species < Taxon
  ActiveRecord::Base.include_root_in_json = false
  validates_presence_of :parent_id, :on => :create, :message => "can't be blank"

  has_many :birth_weights , :dependent => :destroy, :foreign_key => :species_id
  has_many :adult_weights , :dependent => :destroy, :foreign_key => :species_id
  has_many :lifespans     , :dependent => :destroy, :foreign_key => :species_id
  has_many :litter_sizes  , :dependent => :destroy, :foreign_key => :species_id

  default_scope :conditions => {:rank => 6}
  
  def validate
    unless self.parent_id && Taxon.find(self.parent_id) && Taxon.find(self.parent_id).rank == 5
      errors.add_to_base "Species needs to belong to a genus"
    end
  end
  
  def self.rebuild_stats
    connection.execute "
      INSERT INTO statistics
      SELECT
        taxa.id as id,
        taxa.id as taxon_id,

        MIN(lifespans.value_in_days) as minimum_lifespan,
        MIN(adult_weights.value_in_grams) as minimum_adult_weight,
        MIN(litter_sizes.value) as minimum_litter_size,
        MIN(birth_weights.value_in_grams) as minimum_birth_weight,

        MAX(lifespans.value_in_days) as maximum_lifespan,
        MAX(adult_weights.value_in_grams) as maximum_adult_weight,
        MAX(litter_sizes.value) as maximum_litter_size,
        MAX(birth_weights.value_in_grams) as maximum_birth_weight,

        AVG(lifespans.value_in_days) as average_lifespan,
        AVG(adult_weights.value_in_grams) as average_adult_weight,
        AVG(litter_sizes.value) as average_litter_size,
        AVG(birth_weights.value_in_grams) as average_birth_weight,

        STDDEV(lifespans.value_in_days) as standard_deviation_lifespan,
        STDDEV(adult_weights.value_in_grams) as standard_deviation_adult_weight,
        STDDEV(litter_sizes.value) as standard_deviation_litter_size,
        STDDEV(birth_weights.value_in_grams) as standard_deviation_birth_weight

      FROM taxa
      LEFT JOIN lifespans
        ON taxa.id = lifespans.species_id
      LEFT JOIN litter_sizes
        ON taxa.id = litter_sizes.species_id
      LEFT JOIN adult_weights
        ON taxa.id =  adult_weights.species_id
      LEFT JOIN birth_weights
        ON taxa.id =  birth_weights.species_id

      WHERE
        taxa.id IN (
            SELECT species_id FROM lifespans
          UNION
            SELECT species_id FROM birth_weights
          UNION
            SELECT species_id FROM adult_weights
          UNION
            SELECT species_id FROM litter_sizes
        )
      
      GROUP BY taxa.id
    "
    true
  end
  
  def self.species_ids_with_data
    results = ActiveRecord::Base.connection.execute("
      SELECT parent_id
        FROM taxa
        WHERE rank = 6
        AND taxa.id IN (
          SELECT species_id
            FROM lifespans
          UNION SELECT species_id
            FROM birth_weights
          UNION SELECT species_id
            FROM adult_weights
          UNION SELECT species_id
            FROM litter_sizes
        )
        GROUP BY parent_id
        ORDER BY parent_id;
    ")
    results.collect{|result| result["parent_id"].to_i}
  end
  
  def scientific_name
    "#{parent.name} #{name}"
  end
end

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

