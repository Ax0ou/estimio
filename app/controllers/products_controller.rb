class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.by_created_at
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.company = current_user.company

    if @product.save!
      redirect_to products_path, notice: "Produit créé avec succès."
    else
      @products = Product.by_created_at
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      @products = Product.by_created_at
      @product.company = current_user.company

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to products_path, notice: "Produit mis à jour avec succès." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Produit supprimé."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :unit)
  end
end
