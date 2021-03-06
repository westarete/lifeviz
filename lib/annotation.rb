# This is a module to be included in all species annotation models. It has
# functionality common to all of the annotation models.
module Annotation
  def after_save
    if self.species
      self.species.calculate_statistics
    end
  end
  
  def after_destroy
    if self.species
      self.species.calculate_statistics
    end
  end
  
  def add_annotation_point
    if user = User.current_user
      user.karma.tags.add_annotation += 1
    end
  end
  
  def created_by
    if self[:created_by]
      begin
        User.find(self[:created_by])
      rescue ActiveRecord::RecordNotFound
        self[:created_by_name]
      end
    end
  end
  
  def created_by_string
    if created_by.is_a? String
      created_by_name
    else
      if created_by.karma && created_by.karma.to_i > 0
        "#{created_by} [#{created_by.karma}]"
      else
        created_by.to_s
      end
    end
  end
  
  def created_by=(user)
    write_attribute(:created_by, user.id)
    write_attribute(:created_by_name, user.to_s)
  end
  
  def set_created_by
    if user = User.current_user
      self.created_by = user
    end
  end
  
  def context
    (self[:context] && ! self[:context].empty?) ? self[:context] : "No context given."
  end
  
  def citation
    (self[:citation] && ! self[:citation].empty?) ? self[:citation] : "No citation given."
  end
end