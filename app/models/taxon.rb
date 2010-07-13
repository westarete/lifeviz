class Taxon < ActiveRecord::Base
  acts_as_nested_set
  
  before_save :rebuild_lineage_ids
  
  named_scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions), :order => :name} }
  named_scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions), :order => :name} }
  named_scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions), :order => :name} }
  named_scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions), :order => :name} }
  named_scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions), :order => :name} }
  named_scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions), :order => :name} }
  named_scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions), :order => :name} }
  
  validates_presence_of :rank, :message => "must be set"
  validates_presence_of :name, :message => "can't be blank"
  

  def self.rebuild_stats
    rank = 5
    while rank >= 0
      taxon = Taxon.find_all_by_rank(rank)
      progress "Building Taxon Stats for rank #{rank}", taxon.size do |progress_bar|
        taxon.each do |t|
          t.precalculate_stats
          progress_bar.inc
        end
      end
      rank -= 1
    end
  end
  
  def precalculate_stats
    children = self.children
    if children.any?
      self.avg_lifespan     = self.children.collect(&:avg_lifespan).delete_if{|x| x.nil?}.sum     / children.size.to_f
      self.avg_litter_size  = self.children.collect(&:avg_litter_size).delete_if{|x| x.nil?}.sum  / children.size.to_f
      self.avg_adult_weight = self.children.collect(&:avg_adult_weight).delete_if{|x| x.nil?}.sum / children.size.to_f
      self.avg_birth_weight = self.children.collect(&:avg_birth_weight).delete_if{|x| x.nil?}.sum / children.size.to_f
      self.save
    end
  end
  
  def paginated_sorted_species(page)
    begin
      Species.paginate_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC", :page => page)
    rescue
      raise "Left and Right attributes were nil!"
    end
  end
  
  def species
    begin
      @species = Species.find_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC")
    rescue
      raise "Left and Right attributes were nil!"
    end
  end
  
  def complete_species
    species.find_all {|s| s.all_data_available? }
  end
  
  def parents
    lineage_ids.split(/,/).collect { |ancestor_id| Taxon.find(ancestor_id) }
  end
  
  # Rebuild lineage_ids for this taxon.
  def rebuild_lineage_ids
    unless Taxon.first.blank? || parent_id.nil? || parent.lineage_ids.blank?
      self.lineage_ids = (parent.lineage_ids + "," + parent_id.to_s)
    end
  end
  
  # Redefining our own 'root' method, which should run much faster...
  def self.root
    find(1)
  end
  
  # This method rebuilds lineage_ids for the entire taxonomy.
  def self.rebuild_lineages!
    Taxon.find(1).rebuild_lineage_branch(nil) # Run rebuild_lineage on root node.
  end
  
  # This is a recursive method to rebuild a tree of lineage_ids.
  def rebuild_lineage_branch(parent_id, parent_lineage_ids="")
    lineage_ids = if parent_id.nil?  # Root node
                    ""
                  elsif parent_lineage_ids == "" || parent_id == 1 # Child of root node
                    "1"
                  else
                    parent_lineage_ids + "," + parent_id.to_s
                  end     
    
    update_attributes(:lineage_ids => lineage_ids)
    
    unless leaf?
      children.each {|child| child.rebuild_lineage_branch(id, lineage_ids)}
    end
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

