require 'spec_helper'

describe "/taxonomy_navigation/dropdown_options" do
  before(:each) do
    render 'taxonomy_navigation/dropdown_options'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/taxonomy_navigation/dropdown_options])
  end
end
