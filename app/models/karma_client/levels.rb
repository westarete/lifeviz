module KarmaClient
  class Levels
  
    # Takes the current total karma level for this user.
    def initialize(total_karma)
      @total = total_karma
    end
    
    # Is the total enough to warrant at least bronze status?
    def bronze?
      @total >= 3
    end

    # Is the total enough to warrant at least silver status?
    def silver?
      @total >= 5
    end

    # Is the total enough to warrant at least gold status?
    def gold?
      @total >= 8
    end
  
  end
end