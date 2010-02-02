module KarmaClient
  # This class provides the karma interface to the user model. 
  class Karma
    
    # Accepts the user object that we're going to be reporting karma for.
    def initialize(user)
      @user = user
      fetch_karma
    end
    
    # Return the total karma for this user. This is the sum of all the 
    # buckets' karma.
    def total
      self.buckets._total
    end
    
    # Return the levels object for this user.
    def levels
      Levels.new(self.total)
    end
    
    # Return the buckets object for this user.
    def buckets
      Buckets.new(@buckets)
    end
        
    private
    
    # Register our user on the karma server.
    def create_user_on_karma_server
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{@user.karma_permalink}.json")
      resource.put('')
    rescue RestClient::Exception => e
      # TODO: What is the appropriate behavior when this request fails?
      p e.response
      raise
    end
    
    # Retrieve all of the karma information for this user from the server.
    def fetch_karma
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{@user.karma_permalink}/karma.json")
      json = resource.get
      results = ActiveSupport::JSON.decode(json)
      @buckets = results['buckets']
    rescue RestClient::ResourceNotFound
      # If the user is not defined yet, create it and try again.
      create_user_on_karma_server
      retry
    end
    
  end
end