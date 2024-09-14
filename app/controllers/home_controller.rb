class HomeController < ApplicationController
  def index
    redirect_to calendars_path if current_user
  end
end
