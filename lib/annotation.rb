# This is a module to be included in all species annotation models. It has
# functionality common to all of the annotation models.
module Annotation
  def add_annotation_point
    if user = User.current_user
      user.karma.tags.add_annotation += 1
    end
  end
end