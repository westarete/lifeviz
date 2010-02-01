require File.dirname(__FILE__) + '/blank_slate'

module Karma
  
  # A proxy object that behaves exactly like a Fixnum for the total karma
  # value, but is also decorated with accessor methods for each of the 
  # karma buckets. This allows us to have the following behavior:
  #
  #   @user.karma                 # => 12
  #   @user.karma                 # => 12
  #   @user.karma.edits           # => 5
  #   @user.karma.comments        # => 7
  #   @user.karma.comments += 1   # => 8
  #   @user.karma                 # => 13
  #
  class Proxy < BlankSlate
    # Initialize with a hash of all the karma bucket values. The keys are the
    # bucket names as symbols, and the values are the bucket totals.
    def initialize(user)
      @user = user
      fetch_karma
      create_accessors
    end
  
    def method_missing(sym, *args, &block)
      # Proxy any unknown method to the karma total Fixnum object. Since we've
      # stripped away any normal Object functionality by inheriting from
      # BlankSlate, this means that this object will behave almost identically
      # to a Fixnum.
      @total.__send__(sym, *args, &block)
    end

    # Return the karma permalink to use for our user.
    def user_permalink
      # Escaping code is taken from the permalink_fu plugin.
      result = @user.email.dup.to_s
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
      result.downcase!
      result
    end
      
    # Retrieve the karma for this user.
    def fetch_karma
      # resource = RestClient::Resource.new(karma_url, :user => '', :password => KARMA_API_KEY)   # with authentication
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{user_permalink}/karma.json")
      json = resource.get
      results = ActiveSupport::JSON.decode(json)
      @total = results['total']
      @bucket_names = []
      results['buckets'].each do |name, hash|
        @bucket_names << name
        instance_variable_set(:"@#{name}", hash['total'])
      end
    rescue RestClient::Exception
      # TODO: What is the appropriate behavior when the karma server is unreachable?
      nil 
    end
  
    # Returns true if the user has attained a "bronze" karma level.
    def bronze?
      self >= 5
    end
  
    # Returns true if the user has attained a "silver" karma level.
    def silver?
      self >= 10
    end
  
    # Returns true if the user has attained a "gold" karma level.
    def gold?
      self >= 20
    end
    
    private
    
    def update_bucket(bucket_name, adjustment_value)
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{user_permalink}/buckets/#{bucket_name}/adjustments.json")
      resource.post("adjustment[value]=#{adjustment_value}")
    rescue RestClient::Exception => e
      # TODO: What is the appropriate behavior when the karma server is unreachable?
      p e.response
      raise
    end
    
    # Define accessor methods for retrieving and setting the values of each
    # bucket. We are essentially decorating the karma total Fixnum object with
    # these methods.
    def create_accessors
      @bucket_names.each do |bucket_name|
        next if respond_to? bucket_name
        class_eval do
          # Define the getter.
          define_method(bucket_name) do
            instance_variable_get(:"@#{bucket_name}")
          end
          # Define the setter.
          define_method("#{bucket_name}=") do |new_value|
            adjustment_value = new_value - instance_variable_get(:"@#{bucket_name}")
            update_bucket(bucket_name, adjustment_value)
            instance_variable_set(:"@#{bucket_name}", new_value)
            @total += adjustment_value
          end
        end
      end        
    end
  end

end