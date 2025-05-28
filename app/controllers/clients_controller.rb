class ClientsController < ApplicationController
  def index
    @clients = current_user.clients
  end

  def show
    @client = Client.find(params[:id])
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.user_id = current_user.id
    if @client.save
      redirect_to clients_path, notice: "Client créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @client = current_user.clients.find(params[:id])
    if @client.update(client_params)
      redirect_to clients_path, notice: "Client mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @client = current_user.clients.find(params[:id])
  end

  def destroy
    @client = current_user.clients.find(params[:id])
    @client.destroy
    redirect_to clients_path, notice: "Client supprimé avec succès."
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name, :address)
  end
end
