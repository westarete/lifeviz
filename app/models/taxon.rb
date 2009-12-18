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
  
end
