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

class Taxon < ActiveRecord::Base
  acts_as_nested_set
  
  with_options :order => 'name' do |options|
    options.named_scope :kingdoms, :conditions => 'rank = 0'
    options.named_scope :phylums,  :conditions => 'rank = 1'
    options.named_scope :classes,  :conditions => 'rank = 2'
    options.named_scope :orders,   :conditions => 'rank = 3'
    options.named_scope :families, :conditions => 'rank = 4'
    options.named_scope :genuses,  :conditions => 'rank = 5'
    options.named_scope :species,  :conditions => 'rank = 6'
  end                                               
  
end
