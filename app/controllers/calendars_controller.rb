class CalendarsController < ApplicationController
  before_action :authenticate_user

  def index
    @calendars = current_user.calendars.includes(:events)
  end

  def sync
    SyncCalendarsJob.perform_later(current_user.id)
    redirect_to calendars_path, notice: t('calendars.sync.success')
  end
end