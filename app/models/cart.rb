class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_products
  has_many :products, through: :cart_products

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  def calculate_total_price
    cart_products.includes(:product).sum do |cart_product|
      cart_product.quantity * cart_product.product.price
    end
  end
end
