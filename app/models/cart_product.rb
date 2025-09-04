class CartProduct < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  after_save :update_cart_total
  after_destroy :update_cart_total

  private

  def update_cart_total
    cart.update_total_price
  end
end
