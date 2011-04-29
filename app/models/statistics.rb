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

