module KarmaClient
  # This class provides the karma interface to the user model. 
  class Karma
    
    # Accepts the user object that we're going to be reporting karma for.
    def initialize(user)
      @user = user
      fetch_karma
    end
    
    def connected?
      begin
        resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{@user.karma_permalink}/karma.json", "", KARMA_API_KEY)
        json = resource.get
      rescue
        false
      else
        true
      end
    end
    
    # Return the total karma for this user. This is the sum of all the tags' karma.
    def total
      if connected?
        fetch_karma
        self.tags._total
      else
        0
      end
    end
    
    def to_i
      total
    end
    
    def to_s
      total.to_s
    end
    
    # Return the tags object for this user.
    def tags
      Tags.new(@tags)
    end
        
    private
    
    # Register our user on the karma server.
    def create_user_on_karma_server
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{@user.karma_permalink}.json", "", KARMA_API_KEY)
      resource.put('')
    rescue RestClient::Exception => e
      # TODO: What is the appropriate behavior when this request fails?
      p e.response
      raise
    end
    
    # Retrieve all of the karma information for this user from the server.
    def fetch_karma
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}/users/#{@user.karma_permalink}/karma.json", "", KARMA_API_KEY)
      json = resource.get
      results = ActiveSupport::JSON.decode(json)
      @tags = results['tags']
    rescue RestClient::ResourceNotFound
      # If the user is not defined yet, create it and try again.
      create_user_on_karma_server
      retry
    rescue RestClient::Exception => e
      p e.response
      nil
    end
    
  end
end