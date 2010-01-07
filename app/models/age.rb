# == Schema Information
#
# Table name: ages
#
#  id                           :integer         not null, primary key
#  taxon_id                     :integer
#  synonyms                     :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  initial_mortality_rate       :float
#  mortality_rate_doubling_time :float
#  maximum_longevity            :float
#  phenotype                    :string(255)
#

class Age < ActiveRecord::Base
  belongs_to :taxon
  
end
