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
  
  named_scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions), :order => :name} }
  named_scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions), :order => :name} }
  named_scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions), :order => :name} }
  named_scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions), :order => :name} }
  named_scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions), :order => :name} }
  named_scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions), :order => :name} }
  named_scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions), :order => :name} }
  
  def paginated_sorted_species(page)
    Taxon.paginate_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC", :page => page)
  end
  
  def organism
    Organism.find(:first, :conditions => ["taxon_id = ?", id])
  end
  
  def parents
    lineage_ids.split(/,/).collect { |ancestor_id| Taxon.find(ancestor_id) }
  end
  
  def save_under_parent(parent)
    Taxon.transaction do
      save
      move_to_child_of(parent)
    end
  end
  
  def rebuild_lineage(parent_id, parent_lineage_ids="")
    lineage_ids = if parent_id.nil?  # Root node
                    ""
                  elsif parent_lineage_ids == "" || parent_id == 1 # Child of root node
                    "1"
                  else
                    parent_lineage_ids + "," + parent_id.to_s
                  end     
    
    update_attributes(:lineage_ids => lineage_ids)
    
    unless leaf?
      children.each {|child| child.rebuild_lineage(id, lineage_ids)}
    end
  end
  
  def self.rebuild_lineages!
    Taxon.find(1).rebuild_lineage(nil) # Run rebuild_lineage on root node.
  end
  
  # def rebuild_lineage
  #   ancestor_ids = ancestors.collect(&:id)
  #   lineage_ids = ancestor_ids.inject("") do |string, ancestor_id|
  #     # This line turns [1, 2, 3] into "1,2,3".
  #     # That last conditional logic only adds the comma if we're not working
  #     # on the last element. This is HORRIBLE, please refactor!
  #     string += ancestor_id.to_s + (ancestors.last.id != ancestor_id ? "," : "" )
  #   end
  #   update_attributes(:lineage_ids => lineage_ids)
  # end
  # 
  # def self.rebuild_lineages!
  #   Taxon.all.each(&:rebuild_lineage)
  # end
  
end
