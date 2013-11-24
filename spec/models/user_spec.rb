require 'spec_helper'
debugger
describe User do
  it "creates a 100 record" do
    FactoryGirl.create_list(:user, 5)
  end
  
end
