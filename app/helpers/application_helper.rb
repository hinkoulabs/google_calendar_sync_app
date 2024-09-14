module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      notice: "success",
      alert: "danger"
    }[flash_type.to_sym] || flash_type
  end

  def display_time(time)
    time.strftime("%B %d, %Y %H:%M") if time.present?
  end
end
