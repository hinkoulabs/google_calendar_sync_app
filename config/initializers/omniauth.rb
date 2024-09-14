Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], {
    scope: "userinfo.email,calendar",
    access_type: "offline",
    prompt: "consent",
    redirect_uri: ENV["REDIRECT_URI"]
  }
end

OmniAuth.config.allowed_request_methods = %i[get]
