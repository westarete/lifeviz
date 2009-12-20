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
    options.named_scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions)} }
    options.named_scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions)} }
    options.named_scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions)} }
    options.named_scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions)} }
    options.named_scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions)} }
    options.named_scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions)} }
    options.named_scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions)} }
  end                                               
  
  def parents
    lineage_ids.split(/,/).collect { |ancestor_id| Taxon.find(ancestor_id) }
  end
  
  def rebuild_lineage
    update_attributes(:lineage_ids => ancestors.collect(&:id).inject(""){|string, ancestor_id| string += ancestor_id.to_s + (ancestors.last.id != ancestor_id ? "," : "" )})
  end
  
  # Note: This method ONLY works if the database is 'clean', eg. all of the
  # rgt and lft values are set correctly, parent_id is set correctly,
  # no orphan nodes, etc.
  def self.rebuild_lineages!
    Taxon.all.each(&:rebuild_lineage)
  end
  
end
