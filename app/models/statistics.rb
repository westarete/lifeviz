class Statistics < ActiveRecord::Base
  include ActionView::Helpers
  set_table_name "statistics"
  
  TYPES = [:average, :minimum, :maximum, :standard_deviation]
  ANNOTATIONS = {:lifespans     => 'days', 
                 :adult_weights => 'grams',
                 :birth_weights => 'grams',
                 :litter_sizes  => nil}
  MONTH = 30
  YEAR  = 365
  
  belongs_to :taxon, :foreign_key => "taxon_id"
  validates_presence_of :taxon_id
  
  def average_lifespan
    if value = self[:average_lifespan]
      unit = case
              when value / MONTH < 3 then 'day'
              when value / YEAR  < 2 then 'month'
              else                        'year'
              end
      pluralized_unit = value == 1 ? unit : unit.pluralize
      sprintf("%2.2f #{pluralized_unit}", Quantity.new(value, :days).send("to_#{unit}"))
    end
  end
  
  def calculate_lifespan
    result = connection.execute "
      SELECT 
           MIN(lifespans.value_in_days),
           MAX(lifespans.value_in_days),
           AVG(lifespans.value_in_days),
        STDDEV(lifespans.value_in_days)
      FROM taxa
      LEFT OUTER JOIN lifespans
        ON taxa.id = lifespans.species_id
      WHERE 
        taxa.lft >= %s AND 
        taxa.rgt <= %s
    " % [taxon.lft, taxon.rgt]
    self.minimum_lifespan             = result[0]["min"]
    self.maximum_lifespan             = result[0]["max"]
    self.average_lifespan             = result[0]["avg"]
    self.standard_deviation_lifespan  = result[0]["stddev"]
    save!
  end
  
  def calculate_adult_weight
    result = connection.execute "
      SELECT 
           MIN(adult_weights.value_in_grams),
           MAX(adult_weights.value_in_grams),
           AVG(adult_weights.value_in_grams),
        STDDEV(adult_weights.value_in_grams)
      FROM taxa
      LEFT OUTER JOIN adult_weights
        ON taxa.id = adult_weights.species_id
      WHERE 
        taxa.lft >= %s AND 
        taxa.rgt <= %s
    " % [taxon.lft, taxon.rgt]
    self.minimum_adult_weight             = result[0]["min"]
    self.maximum_adult_weight             = result[0]["max"]
    self.average_adult_weight             = result[0]["avg"]
    self.standard_deviation_adult_weight  = result[0]["stddev"]
    save!
  end
  
  def calculate_birth_weight
    result = connection.execute "
      SELECT 
           MIN(birth_weights.value_in_grams),
           MAX(birth_weights.value_in_grams),
           AVG(birth_weights.value_in_grams),
        STDDEV(birth_weights.value_in_grams)
      FROM taxa
      LEFT OUTER JOIN birth_weights
        ON taxa.id = birth_weights.species_id
      WHERE 
        taxa.lft >= %s AND 
        taxa.rgt <= %s
    " % [taxon.lft, taxon.rgt]
    self.minimum_birth_weight             = result[0]["min"]
    self.maximum_birth_weight             = result[0]["max"]
    self.average_birth_weight             = result[0]["avg"]
    self.standard_deviation_birth_weight  = result[0]["stddev"]
    save!
  end
  
  def calculate_litter_size
    result = connection.execute "
      SELECT 
           MIN(litter_sizes.measure),
           MAX(litter_sizes.measure),
           AVG(litter_sizes.measure),
        STDDEV(litter_sizes.measure)
      FROM taxa
      LEFT OUTER JOIN litter_sizes
        ON taxa.id = litter_sizes.species_id
      WHERE 
        taxa.lft >= %s AND 
        taxa.rgt <= %s
    " % [taxon.lft, taxon.rgt]
    self.minimum_litter_size            = result[0]["min"]
    self.maximum_litter_size            = result[0]["max"]
    self.average_litter_size            = result[0]["avg"]
    self.standard_deviation_litter_size = result[0]["stddev"]
    save!
  end
end

# == Schema Information
#
# Table name: statistics
#
#  id                              :integer         not null, primary key
#  taxon_id                        :integer
#  minimum_lifespan                :float
#  minimum_adult_weight            :float
#  minimum_litter_size             :float
#  minimum_birth_weight            :float
#  maximum_lifespan                :float
#  maximum_adult_weight            :float
#  maximum_litter_size             :float
#  maximum_birth_weight            :float
#  average_lifespan                :float
#  average_adult_weight            :float
#  average_litter_size             :float
#  average_birth_weight            :float
#  standard_deviation_lifespan     :float
#  standard_deviation_adult_weight :float
#  standard_deviation_litter_size  :float
#  standard_deviation_birth_weight :float
#  created_at                      :datetime
#  updated_at                      :datetime
#

