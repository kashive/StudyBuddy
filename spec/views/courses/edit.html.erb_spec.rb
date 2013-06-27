require 'spec_helper'

describe "courses/edit" do
  before(:each) do
    @course = assign(:course, stub_model(Course,
      :name => "MyString",
      :term => "MyString",
      :professor => "MyString",
      :number => "MyString"
    ))
  end

  it "renders the edit course form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", course_path(@course), "post" do
      assert_select "input#course_name[name=?]", "course[name]"
      assert_select "input#course_term[name=?]", "course[term]"
      assert_select "input#course_professor[name=?]", "course[professor]"
      assert_select "input#course_number[name=?]", "course[number]"
    end
  end
end
