require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Taxon do
  fixtures :taxa
  
  before(:each) do    
    # Set lft and rgt values for every taxon. Necessary!
    Taxon.rebuild!
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

