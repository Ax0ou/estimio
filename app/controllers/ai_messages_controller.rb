class AiMessagesController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
  end

  def create
  end
end
