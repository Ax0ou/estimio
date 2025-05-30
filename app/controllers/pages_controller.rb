class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    redirect_to quotes_path if user_signed_in?
    @hide_navbar = true
  end
end
