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

  def quote_status_badge(quote)
    status = quote.try(:status) || 'brouillon'
    case status.to_s
    when 'envoye'
      content_tag :span, 'Envoyé', class: 'badge bg-info text-white ms-2 shadow-sm'
    when 'a_traiter'
      content_tag :span, 'À traiter', class: 'badge bg-warning text-dark ms-2 shadow-sm'
    when 'accepte'
      content_tag :span, 'Accepté', class: 'badge bg-success text-white ms-2 shadow-sm'
    when 'refuse'
      content_tag :span, 'Refusé', class: 'badge bg-danger text-white ms-2 shadow-sm'
    when 'facture'
      content_tag :span, 'Facturé', class: 'badge bg-primary text-white ms-2 shadow-sm'
    else
      content_tag :span, 'Brouillon', class: 'badge bg-secondary text-white ms-2 shadow-sm'
    end
  end

  def quote_total_amount(quote)
    total = quote.sections.joins(:line_items).sum('line_items.quantity * line_items.price_per_unit')
    if total > 0
      number_to_currency(total, unit: "€", separator: ",", delimiter: " ", format: "%n %u")
    else
      nil
    end
  end

  def quote_age_indicator(quote)
    days_old = (Date.current - quote.created_at.to_date).to_i
    if days_old > 7
      content_tag :small, class: 'text-muted' do
        content_tag(:i, '', class: 'bi bi-clock-history text-warning') +
        " #{pluralize(days_old, 'jour')}"
      end
    else
      content_tag :small, class: 'text-muted' do
        content_tag(:i, '', class: 'bi bi-clock text-success') + ' Récent'
      end
    end
  end

  def quote_progress_percentage(quote)
    # Calcul simple basé sur le statut
    case quote.try(:status).to_s
    when 'brouillon'
      15
    when 'a_traiter'
      40
    when 'envoye'
      70
    when 'accepte'
      100
    when 'refuse'
      100
    else
      10
    end
  end
end
