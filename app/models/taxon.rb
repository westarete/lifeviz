require 'lib/monkeypatches'

class Taxon < ActiveRecord::Base
  acts_as_nested_set
  
  scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions), :order => :name} }
  scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions), :order => :name} }
  scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions), :order => :name} }
  scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions), :order => :name} }
  scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions), :order => :name} }
  scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions), :order => :name} }
  scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions), :order => :name} }
  
  validates_presence_of :rank, :message => "must be set"
  validates_presence_of :name, :message => "can't be blank"
  
  RANK_LABELS = %w(Kingdom Phylum Class Order Family Genus Species)

  def self.rebuild_stats(rank_specified=nil)
    rank_specified ? (rank = rank_specified) : (rank = 5)
    while rank >= 0
      puts "Calculating size at rank #{RANK_LABELS[rank]}."
      size = Taxon.count(:all, :conditions => {:rank => rank}) / 50
      puts "#{size} batches to complete. Calculating stats at rank #{RANK_LABELS[rank]}."
      progress "Rank: #{rank}", size do |progress_bar|
        Taxon.find_in_batches( :batch_size => 50, :conditions => {:rank => rank} ) do |taxon_batch|
          taxon_batch.each do |t|
            t.precalculate_stats(t.children)
          end
          progress_bar.inc
        end
      end
      puts "Done."
      break unless rank_specified.nil?
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
    avg_lifespan && ! avg_lifespan.be_close(0) &&
    avg_birth_weight && ! avg_birth_weight.be_close(0) &&
    avg_adult_weight && ! avg_adult_weight.be_close(0) &&
    avg_litter_size && ! avg_litter_size.be_close(0)
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
    
  def precalculate_stats(children = self.children)
    if children.any?
      [:avg_lifespan, :avg_litter_size, :avg_adult_weight, :avg_birth_weight].each do |property|
        self[property]= calculate_avg(children.collect(&property))
      end
      self.save
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
  
  def calculate_avg(array)
    sum = array.delete_if{|x| x.nil? || x.be_close(0.0, 0.00000000000001)}.sum
    if sum != 0
      sum / array.size.to_f
    else
      nil
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
