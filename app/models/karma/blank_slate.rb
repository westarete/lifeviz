module Karma

  # A class that has had all instance methods stripped except for __id__ and
  # __send__. This provides the basis for a good proxy object.
  #
  # Thanks to Jim Weirich for the idea and explanation:
  # http://onestepback.org/index.cgi/Tech/Ruby/BlankSlate.rdoc
  class BlankSlate 
    # These are the only methods we want to keep.
    keepers = [
      # These two are necessary so that our proxy object can function as
      # a proper independent object.
      '__id__', 
      '__send__', 
      # We need the next two so that we can still define methods dynamically.
      'class_eval', 
      'metaclass',
    ]
    # Remove all instance methods other than the keepers.
    (instance_methods - keepers).each { |m| undef_method m }
  end

end