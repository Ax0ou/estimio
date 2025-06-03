class ClientsController < ApplicationController
  before_action :set_company, only: [:new, :create, :destroy, :edit, :update]

  def index
    @clients = current_user.company.clients
  end

  def show
    @client = Client.find(params[:id])
  end

  def new
    @client = @company.clients.new
  end

  def create
    @client = @company.clients.new(client_params)

    if @client.save
      redirect_to company_clients_path, notice: "Client créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @client = @company.clients.find(params[:id])
    if @client.update(client_params)
      redirect_to company_clients_path(@company), notice: "Client mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @client = @company.clients.find(params[:id])
  end

  def destroy
    @client = @company.clients.find(params[:id])
    @client.destroy
    redirect_to company_clients_path(@company), notice: "Client supprimé avec succès."
  end

  private

  def client_params
    params.require(:client).permit(:first_name, :last_name, :address)
  end

  def set_company
    @company = current_user.company
  end
end
