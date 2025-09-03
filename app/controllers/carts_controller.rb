class CartsController < ApplicationController
  def index
    @carts = Cart.all

    render json: @carts
  end

  def show
    render json: current_cart, serializer: CartSerializer
  end

  def create
    product_id = params.require(:product_id)
    quantity = params.require(:quantity)

    @cart = CartService.new(current_cart, product_id, quantity).add_product

    render json: @cart, serializer: CartSerializer, status: :created
  end

  def destroy
    product_id = params.require(:id)

    @cart = CartService.new(current_cart, product_id).remove_product

    render json: @cart, serializer: CartSerializer, status: :ok
  end

  private

  def current_cart
    Cart.last
  end
end
