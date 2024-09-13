class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_user
    redirect_to root_path unless session[:user_id].present?
  end

  private

  def google_auth
    credentials = session[:credentials]
    Signet::OAuth2::Client.new(
      access_token: credentials['token'],
      refresh_token: credentials['refresh_token'],
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )
  end
end
