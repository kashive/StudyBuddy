FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "foo#{n}" }
    password "foobarisawesome"
    email { "#{first_name}@brandeis.edu" }   
  end

  factory :course do
    name "Introduction to economics"
    professor "Coiner"
    user
  end
end