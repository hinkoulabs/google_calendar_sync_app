# Google Calendar Sync App

[![CI](https://github.com/hinkoulabs/google_calendar_sync_app/actions/workflows/ci.yml/badge.svg)](https://github.com/hinkoulabs/google_calendar_sync_app/actions/workflows/ci.yml)

## 1. Description

The **Google Calendar Sync App** allows users to log in using their Google account and synchronize their Google Calendar data with the application. The project utilizes **PostgreSQL** as the database, **Redis** for broadcasting Turbo Streams, and **Sidekiq** for background job processing to handle parallel calendar synchronization. This ensures users can manage and sync their Google Calendar events efficiently.

## 2. Installation (Development)

### Prerequisites

- **Docker** and **Docker Compose** installed on your machine.
- Google OAuth2 credentials (Client ID and Client Secret) from the **Google Developer Console**.

### Steps to Install and Run the Project

1. **Clone the repository:**

   ```
   git clone <repository_url>
   cd google_calendar_sync_app
   ```

2. **Build and run the Docker containers:**

   ```
   docker-compose build
   docker-compose up -d
   ```

3. **Set up the database:**

   Access the app container and run the database setup commands:

   ```
   docker-compose exec web bundle exec rails db:create
   docker-compose exec web bundle exec rails db:migrate
   ```

4. **Set up the environment variables:**

   Create a `.env` file in the project root directory with the following content:

   ```
   # Google OAuth credentials
   GOOGLE_CLIENT_ID=
   GOOGLE_CLIENT_SECRET=

   # Google OAuth callback URL
   REDIRECT_URI='http://localhost:3000/auth/google_oauth2/callback'

   # PostgreSQL database credentials
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgres
   POSTGRES_DB=google_calendar_sync_app_development

   # Rails master key for encrypted credentials
   RAILS_MASTER_KEY=c4f20b83e667653040bb7ef740c4682c
   RAILS_ENV=development
   ```

   **Note**: You need to set the `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` values by creating a project in the [Google Developer Console](https://console.developers.google.com/) and setting up OAuth credentials.

5. **Access the app:**

   The app should now be accessible at:

   ```
   http://localhost:3000
   ```

## 3. Features

- **Google OAuth2 Authentication**: Users can log in using their Google account.
- **Calendar Synchronization**: The app synchronizes Google Calendar data, including events, with the local database.
- **Turbo Streams**: Real-time updates using Redis-backed Turbo Streams for broadcasting updates.
- **Background Job Processing**: Sidekiq is used to handle calendar synchronization tasks in parallel, improving the performance for multiple calendars.

## 4. Technologies Used

- **Ruby on Rails**: Web application framework.
- **PostgreSQL**: Relational database management system.
- **Redis**: In-memory data store used for Turbo Streams.
- **Sidekiq**: Background job processor for handling calendar sync jobs in parallel.
- **Docker**: Containerization of the development environment for easy setup and deployment.

## 5. Setup Google OAuth2

To get the `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`, follow these steps:

1. Go to the [Google Developer Console](https://console.developers.google.com/).
2. Create a new project.
3. Go to the **Credentials** section and create an **OAuth 2.0 Client ID**.
4. Set the **Authorized redirect URIs** to `http://localhost:3000/auth/google_oauth2/callback`.
5. Copy the generated **Client ID** and **Client Secret** to your `.env` file.