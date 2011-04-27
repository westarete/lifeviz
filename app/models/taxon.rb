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
  # TODO: I haven't actually tried this code yet, because it still takes a while
  # to run! If you run it successfully, remove this TODO, please!
  def self.rebuild_lineages!
    logger.info "Creating kingdom lineage ids"
    self.connection.execute "
    update taxa
      set lineage_ids = 1
      where rank = 0;
    "
    
    %w(phylum class order family genus species).each_with_index do |name, i|
      logger.info "Creating #{name} lineage ids"
      self.connection.execute "
      update taxa
        set lineage_ids = parent.lineage_ids || ',' || taxa.id
        from taxa parent
        where
          taxa.rank = #{i + 1}
          and taxa.parent_id = parent.id;
      "
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
    
    
    # Makes our 1D array into a 2D array
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

