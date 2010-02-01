module KarmaClient
  # This class provides the karma interface to the user model. 
  class Karma
    
    # Accepts the user object that we're going to be reporting karma for.
    def initialize(user)
      @user = user
    end
    
  end
end