class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    redirect_to company_quotes_path(current_user.company_id) if user_signed_in?
    @hide_navbar = true
  end
end
