class GetInTouchesController < ApplicationController
  # GET /get_in_touches
  # GET /get_in_touches.json
  skip_before_filter :authenticate_user!
  def index
    @get_in_touches = GetInTouch.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @get_in_touches }
    end
  end

  # GET /get_in_touches/new
  # GET /get_in_touches/new.json
  def new
    @get_in_touch = GetInTouch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @get_in_touch }
    end
  end

  # POST /get_in_touches
  # POST /get_in_touches.json
  def create
    @get_in_touch = GetInTouch.new(params[:get_in_touch])

    respond_to do |format|
      if @get_in_touch.save && !user_signed_in?
        format.html { redirect_to root_path, notice: 'Your response was recorded. Thank you for contacting us!' }
        format.json { render json: @get_in_touch, status: :created, location: @get_in_touch }
      elsif @get_in_touch.save && user_signed_in?
        format.html { redirect_to dashboard_path(current_user), notice: 'Your response was recorded. Thank you for contacting us!' }
        format.json { render json: @get_in_touch, status: :created, location: @get_in_touch }
      else
        format.html { redirect_to root_path }
        format.json { render json: @get_in_touch.errors, status: :unprocessable_entity }
      end
    end
  end
end
