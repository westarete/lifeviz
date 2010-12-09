class Statistics < ActiveRecord::Base
  include ActionView::Helpers
  set_table_name "statistics"
  
  TYPES = [:average, :minimum, :maximum, :standard_deviation]
  ANNOTATIONS = {:lifespans     => 'days', 
                 :adult_weights => 'grams',
                 :birth_weights => 'grams',
                 :litter_sizes  => nil}
  MONTH    = 30
  YEAR     = 365
  KILOGRAM = 1000
  
  belongs_to :taxon, :foreign_key => "taxon_id"
  validates_presence_of :taxon_id

  TYPES.each do |type|
    # Define lifespan getters.
    variable_name = "#{type}_lifespan"
    define_method(variable_name) do
      if value = self[variable_name]
        unit = case
                when value / MONTH < 3 then 'day'
                when value / YEAR  < 2 then 'month'
                else                        'year'
                end
        pluralized_unit = value == 1 ? unit : unit.pluralize
        number_to_currency(Quantity.new(value, :days).send("to_#{unit}"), 
                           :unit => pluralized_unit,
                           :separator => ".",
                           :delimiter => ",",
                           :format => "%n %u")
      end
    end
  end
  
  TYPES.each do |type|
    # Define adult_weight getters.
    variable_name = "#{type}_adult_weight"
    define_method(variable_name) do
      if value = self[variable_name]
        unit = case
                when value / KILOGRAM < 1 then 'gram'
                else                           'kilogram'
                end
        pluralized_unit = value == 1 ? unit : unit.pluralize
        number_to_currency(value.grams.send("to_#{unit}"), 
                           :unit => pluralized_unit,
                           :separator => ".",
                           :delimiter => ",",
                           :format => "%n %u")
      end
    end
  end
  
  TYPES.each do |type|
    # Define birth_weight getters.
    variable_name = "#{type}_birth_weight"
    define_method(variable_name) do
      if value = self[variable_name]
        unit = case
                when value / KILOGRAM < 1 then 'gram'
                else                           'kilogram'
                end
        pluralized_unit = value == 1 ? unit : unit.pluralize
        number_to_currency(value.grams.send("to_#{unit}"), 
                           :unit => pluralized_unit,
                           :separator => ".",
                           :delimiter => ",",
                           :format => "%n %u")
      end
    end
  end
  
  TYPES.each do |type|
    # Define litter_size getters.
    variable_name = "#{type}_litter_size"
    define_method(variable_name) do
      if self[variable_name]
        number_to_currency(self[variable_name],
                           :separator => ".",
                           :delimiter => ",",
                           :format => "%n")
      else
        ""
      end
    end
  end
  
  def calculate_statistics
    result = connection.execute "
      SELECT 
        MIN(lifespans.value_in_days) as minimum_lifespan,
        MAX(lifespans.value_in_days) as maximum_lifespan,
        AVG(lifespans.value_in_days) as average_lifespan,
        STDDEV(lifespans.value_in_days) as standard_deviation_lifespan,
        MIN(litter_sizes.value) as minimum_litter_size,
        MAX(litter_sizes.value) as maximum_litter_size,
        AVG(litter_sizes.value) as average_litter_size,
        STDDEV(litter_sizes.value) as standard_deviation_litter_size,
        MIN(adult_weights.value_in_grams) as minimum_adult_weight,
        MAX(adult_weights.value_in_grams) as maximum_adult_weight,
        AVG(adult_weights.value_in_grams) as average_adult_weight,
        STDDEV(adult_weights.value_in_grams) as standard_deviation_adult_weight,
        MIN(birth_weights.value_in_grams) as minimum_birth_weight,
        MAX(birth_weights.value_in_grams) as maximum_birth_weight,
        AVG(birth_weights.value_in_grams) as average_birth_weight,
        STDDEV(birth_weights.value_in_grams) as standard_deviation_birth_weight
      FROM taxa
      LEFT OUTER JOIN lifespans
        ON taxa.id = lifespans.species_id
      LEFT OUTER JOIN litter_sizes
        ON taxa.id = litter_sizes.species_id
      LEFT OUTER JOIN adult_weights
        ON taxa.id =  adult_weights.species_id
      LEFT OUTER JOIN birth_weights
        ON taxa.id =  birth_weights.species_id
      WHERE
        taxa.lft >= %s AND
        taxa.rgt <= %s
    " % [taxon.lft, taxon.rgt]
    self.minimum_lifespan                 = result[0]["minimum_lifespan"]
    self.maximum_lifespan                 = result[0]["maximum_lifespan"]
    self.average_lifespan                 = result[0]["average_lifespan"]
    self.standard_deviation_lifespan      = result[0]["standard_deviation_lifespan"]
    self.minimum_adult_weight             = result[0]["minimum_litter_size"]
    self.maximum_adult_weight             = result[0]["maximum_litter_size"]
    self.average_adult_weight             = result[0]["average_litter_size"]
    self.standard_deviation_adult_weight  = result[0]["standard_deviation_litter_size"]
    self.minimum_birth_weight             = result[0]["minimum_adult_weight"]
    self.maximum_birth_weight             = result[0]["maximum_adult_weight"]
    self.average_birth_weight             = result[0]["average_adult_weight"]
    self.standard_deviation_birth_weight  = result[0]["standard_deviation_adult_weight"]
    self.minimum_litter_size              = result[0]["minimum_birth_weight"]
    self.maximum_litter_size              = result[0]["maximum_birth_weight"]
    self.average_litter_size              = result[0]["average_birth_weight"]
    self.standard_deviation_litter_size   = result[0]["standard_deviation_birth_weight"]
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

