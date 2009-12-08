module SeedMethods  
  

  # Display a progress bar. The block variable is the progress bar object.
  # Presumes that we will increment for each line in the input file.
  def progress(phrase, count, &block)
    # Create the progress bar.
    progress_bar = ProgressBar.new(phrase, count)
    # Let the block do its work.
    yield progress_bar
    # Done with the progress bar.
    progress_bar.finish    
  end
end