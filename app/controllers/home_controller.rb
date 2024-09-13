class HomeController < ApplicationController
  def index
    redirect_to calendars_path if session[:user_id]
  end
end
