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
    def initialize(buckets)
      @buckets = buckets
      create_accessors
    end
  
    def method_missing(sym, *args, &block)
      # Proxy any unknown method to the karma total Fixnum object. Since we've
      # stripped away any normal Object functionality by inheriting from
      # BlankSlate, this means that this object will behave almost identically
      # to a Fixnum.
      @buckets.values.sum.__send__(sym, *args, &block)
    end
    
    private
    
    # Define accessor methods for retrieving and setting the values of each
    # bucket. We are essentially decorating the karma total Fixnum object with
    # these methods.
    def create_accessors
      @buckets.keys.each do |bucket_name|
        class_eval do
          # Define the getter.
          define_method(bucket_name) do
            @buckets[bucket_name]
          end
          # Define the setter.
          define_method("#{bucket_name}=") do |new_value|
            @buckets[bucket_name] = new_value
          end
        end
      end        
    end
  end

end