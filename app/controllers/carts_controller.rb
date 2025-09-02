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

    puts @cart.inspect
    if @cart.persisted?
      render json: @cart, serializer: CartSerializer, status: :ok
    else
      render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def current_cart
    Cart.find_or_create_by(id: session[:cart_id]).tap do |cart|
      session[:cart_id] ||= cart.id
    end
  end
end
