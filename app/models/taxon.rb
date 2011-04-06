require 'lib/monkeypatches'
require 'db/seed_methods'
include SeedMethods

class Taxon < ActiveRecord::Base
  acts_as_nested_set
  
  named_scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions), :order => :name} }
  named_scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions), :order => :name} }
  named_scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions), :order => :name} }
  named_scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions), :order => :name} }
  named_scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions), :order => :name} }
  named_scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions), :order => :name} }
  named_scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions), :order => :name} }
  
  has_one :statistics, :dependent => :destroy
  has_many :citations
  has_many :references, :through => :citations
  
  validates_presence_of :rank, :message => "must be set"
  validates_presence_of :name, :message => "can't be blank"
  
  RANK_LABELS = %w(Kingdom Phylum Class Order Family Genus Species)
  
  after_create :create_statistics_object
  
  # This method rebuilds lineage_ids for the entire taxonomy.
  def self.rebuild_lineages!
    Taxon.find(1).rebuild_lineage_branch
  end

  # This is a recursive method to rebuild a tree of lineage_ids.
  def rebuild_lineage_branch(parent_id=nil, parent_lineage_ids="")
    # print "| " * rank unless rank == -1
    # print "Calculating lineage for #{id}: #{name}..."
    lineage_ids = if parent_id.nil?  # Root node
                    ""
                  elsif parent_lineage_ids == "" || parent_id == 1 # Child of root node
                    "1"
                  else
                    parent_lineage_ids + "," + parent_id.to_s
                  end     
 
    update_attributes(:lineage_ids => lineage_ids)
    # puts " success!"
 
    unless rank == 6
      children.each {|child| child.rebuild_lineage_branch(id, lineage_ids)}
    end
  end
  
  def self.rebuild_statistics_objects
    # # Fast, uninformative method!
    ActiveRecord::Base.connection.execute <<-sql
      insert into statistics (taxon_id) 
        select t.id
        from taxa t 
        where not exists (
          select taxon_id
          from statistics
          where taxon_id=t.id
        );
    sql
    # # Slow but informative method
    # Rails.logger.info "Collecting taxon ids"
    # taxon_ids = Taxon.find(:all, :select => "id").collect(&:id)
    # Rails.logger.info "Collecting statistics taxon ids"
    # statistics_taxon_ids = Statistics.find(:all, :select => "taxon_id").collect(&:taxon_id)
    # Rails.logger.info "Finding taxa without statistics objects"
    # statistics_to_create = taxon_ids - statistics_taxon_ids
    # Rails.logger.info "Creating statistics objects"
    # progress    "Creating", statistics_to_create.count do |progress_bar|
    #   statistics_to_create.each do |taxon_id|
    #     Statistics.create(:taxon_id => taxon_id)
    #     progress_bar.inc
    #   end
    # end
  end
  
  def self.rebuild_stats(rank=6)
    while rank >= 0
      size = Taxon.count(:all, :conditions => {:rank => rank})
      progress "#{RANK_LABELS[rank]}", size do |progress_bar|
        Taxon.find(:all, :conditions => {:rank => rank} ).each do |taxon|
          taxon.statistics.calculate_statistics
          progress_bar.inc
        end
      end
      rank -= 1
    end
  end
  
  # Redefining our own 'root' method, which should run much faster...
  def self.root
    find(1)
  end
  
  def self.find_by_name_and_rank(name, rank)
    rank_match = RANK_LABELS.find { |l| l.downcase == rank.downcase }
    rank_match_index = RANK_LABELS.index(rank_match)
    self.find(:first, :conditions => {:name => name.capitalize, :rank => rank_match_index})
  end
  
  def all_data_available?
    # this used to have be_close clauses, but they stopped working because Statistics now returns strings instead of floats
    not (self.statistics.average_lifespan.blank? or 
         self.statistics.average_birth_weight.blank? or 
         self.statistics.average_adult_weight.blank? or
         self.statistics.average_litter_size.blank? )
  end
  
  def parents
    Taxon.find(hierarchy, :order => 'rank ASC')
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
  
  def rank_in_words
    RANK_LABELS[self.rank.to_i]
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
  
  private
  
  def create_statistics_object
    Rails.logger.info "Creating statistics for taxon #{self.id}"
    self.create_statistics
  end
  
end

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

