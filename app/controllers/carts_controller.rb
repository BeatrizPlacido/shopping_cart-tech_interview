class CartsController < ApplicationController
  before_action :set_cart, only: %i[ show ]

  def index
    @carts = Cart.all

    render json: @carts
  end

  def show
    render json: @cart
  end

  def create
    @cart = CartService.new.create_cart

    if @cart.save
      render json: @cart, status: :created, location: @cart
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = Cart.find(params[:id])
  end
end
