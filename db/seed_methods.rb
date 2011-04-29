require 'benchmark'
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
      state = nil
      time = Benchmark.realtime do
        print seed_string(text)
        state = yield
      end
      time_elapsed = "%.1f" % [time]
      if state == true
        puts success_string(args[:success]) + " in #{time_elapsed} seconds\n"
      elsif state == false
        puts failure_string(args[:failure]) + "\n"
      else  # state == nil
        puts info_string(args[:notice]) + " in #{time_elapsed} seconds\n"
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
  
  def seed_section(text, &block)
    print colorize("***#{text}", '[1;30m')
    if text.length < 27
      print colorize('*' * (27 - text.length), '[1;30m')
    end
    print '\n'
    
    time = Benchmark.realtime do
      yield
    end
    
    text = "%.1f s" % [time]
    print colorize("***#{text}", '[1;30m')
    if text.length < 27
      print colorize('*' * (27 - text.length), '[1;30m')
    end
    print '\n'
  end
  
  def notice(text)
    puts "   #{text}"
  end
  
end
