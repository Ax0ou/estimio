module FlashConcern
  extend ActiveSupport::Concern

  private

  def flash_success(message)
    flash[:success] = message
  end

  def flash_error(message)
    flash[:error] = message
  end

  def flash_warning(message)
    flash[:warning] = message
  end

  def flash_info(message)
    flash[:info] = message
  end

  # Maintenir la compatibilité avec les notices et alerts existantes
  def flash_notice(message)
    flash[:notice] = message
  end

  def flash_alert(message)
    flash[:alert] = message
  end
end
