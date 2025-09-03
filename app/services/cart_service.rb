class CartService
  def initialize(current_cart, product_id, quantity = 1)
    @cart = current_cart
    @product_id = product_id
    @quantity = quantity
  end

  def add_product
    create_cart_product
    update_cart_total_price

    cart.reload
  end

  def remove_product
    raise ActiveRecord::RecordNotFound, 'Product does not exists on current cart session' if cart_product.blank? || cart_product.quantity < 1

    cart_product.quantity -= quantity.to_i
    cart_product.save
    cart_product.destroy if cart_product.quantity.zero?
    update_cart_total_price

    cart.reload
  end

  private

  attr_reader :cart, :product_id, :quantity

  def create_cart_product
    return CartProduct.create!(cart:, product:, quantity:) if cart_products.blank?

    cart_product.quantity += quantity.to_i
    cart_product.save
  end

  def update_cart_total_price
    cart.update(total_price: cart.calculate_total_price)
  end

  def product
    @product ||= Product.find(product_id)
  end

  def cart_product
    @cart_product ||= CartProduct.find_by(cart_id: cart.id, product_id:)
  end
end
