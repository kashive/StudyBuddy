require 'spec_helper'

describe "courses/index" do
  before(:each) do
    assign(:courses, [
      stub_model(Course,
        :name => "Name",
        :term => "Term",
        :professor => "Professor",
        :number => "Number"
      ),
      stub_model(Course,
        :name => "Name",
        :term => "Term",
        :professor => "Professor",
        :number => "Number"
      )
    ])
  end

  it "renders a list of courses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Term".to_s, :count => 2
    assert_select "tr>td", :text => "Professor".to_s, :count => 2
    assert_select "tr>td", :text => "Number".to_s, :count => 2
  end
end
