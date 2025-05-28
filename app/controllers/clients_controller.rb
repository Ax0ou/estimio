class ClientsController < ApplicationController
  def index
    @clients = current_user.clients
    raise
  end

  def show
    @client = Client.find[params[:id]]
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.user_id = current_user
    if @client.save
      redirect_to clients_show_path(@client)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def udpate
  end

  def edit
  end

  def destroy
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name, :address, :user_id)
  end
end
