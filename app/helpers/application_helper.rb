module ApplicationHelper
  def time_range(appointment)
    "#{appointment.starts_at.strftime('%-l:%M %p')} – #{appointment.ends_at.strftime('%-l:%M %p')}"
  end
end
