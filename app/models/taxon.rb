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
  
  RANK_LABELS = %w(Kingdom Phylum Class Order Family Genus Species)
  
  # This method rebuilds lineage_ids for the entire taxonomy.
  def self.rebuild_lineages!
    Taxon.find(1).rebuild_lineage_branch(nil) # Run rebuild_lineage on root node.
  end

  def self.rebuild_stats(rank_specified=nil)
    rank_specified ? (rank = rank_specified) : (rank = 5)
    while rank >= 0      
      size = Taxon.count(:all, :conditions => {:rank => rank}) / 50
      progress "Building Taxon Stats for rank #{rank}", size do |progress_bar|
        Taxon.find_in_batches( :batch_size => 50 ) do |taxon_batch|
          taxon_batch.each do |t|
            t.precalculate_stats
          end
          progress_bar.inc
        end
      end      
      break unless rank_specified.nil?
      rank -= 1
    end
  end
  
  # Redefining our own 'root' method, which should run much faster...
  def self.root
    find(1)
  end
  
  def all_data_available?
    avg_lifespan && avg_lifespan != 0 &&
    avg_birth_weight && avg_birth_weight != 0 &&
    avg_adult_weight && avg_adult_weight != 0 &&
    avg_litter_size && avg_litter_size != 0
  end
  
  def parents
    lineage_ids.split(/,/).collect { |ancestor_id| Taxon.find(ancestor_id) }
  end
  
  def children_of_rank(rank)
    if rank && self.rank < rank
      rank = 6 if rank > 6
      Species.find_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = #{rank} ORDER BY name ASC")
    else
      raise 'rank not set properly'
    end
  end
  
  # returns an array of arrays. 
  # full_ancestry[0] is an array of the ancestors at rank 0
  # full_ancestry[1] is an array of the ancestors at rank 1, etc
  def full_ancestry(options = {})
    options = {:include_children => false}.merge(options)
    
    hierarchy_array = self.hierarchy
    hierarchy_array << 1 # for the top-level, rank0 terms
    hierarchy_array << self.id if options[:include_children]

    ancestry = self.class.find_all_by_parent_id(hierarchy_array, :order => 'rank asc, name asc')
  
  
    # Makes our 1D array into a 2D array ordered by     
    returning Array.new do |ranked_ancestry|
      ancestry.each do |term|
        rank = term.rank.to_i
        ranked_ancestry[rank] ||= []
        ranked_ancestry[rank] << term
      end
    end
  end
  
  def hierarchy
    if self.lineage_ids.nil?
      []
    else
      self.lineage_ids.split(',').map{|id| id.to_i}
    end
  end
    
  def paginated_sorted_species(page)
    begin
      Species.paginate_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC", :page => page)
    rescue
      raise "Left and Right attributes were nil!"
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
  
  def rank_in_words
    RANK_LABELS[self.rank.to_i]
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
  
  # Rebuild lineage_ids for this taxon.
  def rebuild_lineage_ids
    unless Taxon.first.blank? || parent_id.nil? || parent.lineage_ids.blank?
      self.lineage_ids = (parent.lineage_ids + "," + parent_id.to_s)
    end
  end
  
  def scientific_name 
    (id == 1) ? 'All Taxa' : read_attribute(:name)
  end
  
  def species
    begin
      @species = Species.find_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC")
    rescue
      raise "Left and Right attributes were nil!"
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

