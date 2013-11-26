class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!  
  def idea
  end

  def how
  end

  def team
  end

  def bugs
  end
  
end
