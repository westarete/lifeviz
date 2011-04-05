module SeedMethods
  
  # Display a progress bar. The block variable is the progress bar object.
  # Presumes that we will increment for each line in the input file.
  def progress(phrase, count, &block)
    # Add space up front
    phrase = "   " << phrase
    # Create the progress bar.
    progress_bar = ProgressBar.new(phrase, count)
    # Let the block do its work.
    yield progress_bar
    # Done with the progress bar.
    progress_bar.finish    
  end

  def colorize(text, color_code)
    "\033#{color_code}#{text}\033[0m"
  end
  
  def seed(text, args={}, &block)
    if block_given?
      print seed_string(text)
      state = yield
      if state == true
        puts success_string(args[:success]) + "\n"
      elsif state == false
        puts failure_string(args[:failure]) + "\n"
      else  # state == nil
        puts info_string(args[:notice]) + "\n"
      end
      if args[:quit]
        exit!
      end
    else
      puts seed_string(text)
    end
  end

  def failure_string(text=nil)
    returning string = "" do
      string << colorize("failure", "[31m")
      string << ": #{text}" if text
    end
  end
  
  def success_string(text=nil)
    returning string = "" do
      string << colorize("success", "[32m")
      string << ": #{text}" if text
    end
  end
  
  def info_string(text=nil)
    returning string = "" do
      string << colorize("completed", "[36m")
      string << ": #{text}" if text
    end
  end
  
  def seed_string(text)
    colorize('**', '[1;30m') << " #{text}... "
  end
  
  def notice(text)
    puts "   #{text}"
  end
  
end
