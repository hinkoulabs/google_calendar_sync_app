require 'google/apis/calendar_v3'
class GoogleCalendarJob < ApplicationJob
  protected

  def init_google_service(user)
    client = Signet::OAuth2::Client.new(
      access_token: user.access_token,
      refresh_token: user.refresh_token,
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
    )

    if client.expired?
      client.refresh!
      user.update(access_token: client.access_token)
    end

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service
  end
end
