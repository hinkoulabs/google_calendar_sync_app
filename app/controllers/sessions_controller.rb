class SessionsController < ApplicationController
  def create
    user_info = request.env['omniauth.auth']

    # find or create the user based on the Google UID
    @user = User.find_or_create_by(google_id: user_info['uid']) do |user|
      user.email = user_info['info']['email']
      user.name = user_info['info']['name']
    end

    # update the access_token and refresh_token every time the user logs in
    @user.update(
      access_token: user_info['credentials']['token'],
      # only update refresh_token if present
      refresh_token: user_info['credentials']['refresh_token'] || @user.refresh_token
    )

    # save the user id in the session to keep the user logged in
    session[:user_id] = @user.id

    redirect_to calendars_path, notice: I18n.t('sessions.create.success')
  end

  def destroy
    session.clear
    redirect_to root_path, notice: I18n.t('sessions.destroy.success')
  end
end