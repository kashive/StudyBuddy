require 'spec_helper'

describe "courses/new" do
  before(:each) do
    assign(:course, stub_model(Course,
      :name => "MyString",
      :term => "MyString",
      :professor => "MyString",
      :number => "MyString"
    ).as_new_record)
  end

  it "renders new course form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", courses_path, "post" do
      assert_select "input#course_name[name=?]", "course[name]"
      assert_select "input#course_term[name=?]", "course[term]"
      assert_select "input#course_professor[name=?]", "course[professor]"
      assert_select "input#course_number[name=?]", "course[number]"
    end
  end
end
