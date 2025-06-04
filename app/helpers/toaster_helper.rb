module ApplicationHelper
  def toaster_icon(flash_type)
    case flash_type.to_s
    when "notice", "success" then "bi-check-circle-fill"
    when "alert", "error" then "bi-exclamation-triangle-fill"
    when "warning" then "bi-exclamation-circle-fill"
    when "info" then "bi-info-circle-fill"
    else "bi-bell-fill"
    end
  end

  def toaster_background_class(flash_type)
    case flash_type.to_s
    when "notice", "success" then "bg-success bg-opacity-75"
    when "alert", "error" then "bg-danger bg-opacity-75"
    when "warning" then "bg-warning bg-opacity-75"
    when "info" then "bg-info bg-opacity-75"
    else "bg-secondary bg-opacity-75"
    end
  end

  def toaster_text_class(flash_type)
    case flash_type.to_s
    when "warning" then "text-dark"
    else "text-white"
    end
  end

  def toaster_header_text(flash_type)
    case flash_type.to_s
    when "notice", "success" then "Succès"
    when "alert", "error" then "Erreur"
    when "warning" then "Attention"
    when "info" then "Information"
    else "Notification"
    end
  end
end
