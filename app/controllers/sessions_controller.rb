class SessionsController < ApplicationController
  def create
    user_info = request.env['omniauth.auth']
    session[:user_id] = user_info['uid']
    session[:credentials] = user_info['credentials']

    redirect_to calendars_path, notice: 'Successfully logged in with Google!'
  end

  def destroy
    session.clear
    redirect_to root_path, notice: 'Logged out successfully!'
  end
end