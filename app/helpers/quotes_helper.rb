module QuotesHelper
  def status_badge_class(status)
    case status.to_s
    when "a_traiter" then "bg-secondary text-white"
    when "envoye" then "bg-success text-white"
    else "bg-light text-dark"
    end
  end

  def status_text(status)
    case status.to_s
    when "a_traiter" then "À traiter"
    when "envoye" then "Envoyé"
    else "Inconnu"
    end
  end

  def status_icon(status)
    case status.to_s
    when "a_traiter" then "bi-pencil"
    when "envoye" then "bi-send"
    else "bi-question"
    end
  end
end
