class UsersController < ApplicationController

  def home
  end

  def new
    @craftman = Craftman.new
  end

  def create
    @craftman = Craftman.new(craftman_params)
    if @craftman.save
      redirect_to user_quotes_path
    else
      render :new
    end
  end

  private

  def craftman_params
    params.require(:craftman).permit(:first_name, :last_name, :siret, :company_name, :address, :phone_number)
  end
end
