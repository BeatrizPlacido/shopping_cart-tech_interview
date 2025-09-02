class CartService
  def initialize(current_cart, product_id, quantity)
    @cart = current_cart
    @product_id = product_id
    @quantity = quantity
  end

  def add_product
    create_cart_product
    update_cart_total_price

    cart.reload
  end

  private

  attr_reader :cart, :product_id, :quantity

  def create_cart_product
    return CartProduct.create(cart:, product:, quantity:) if cart_products.blank?

    cart_product = cart_products.first
    cart_product.quantity += quantity.to_i
    cart_product.save
  end

  def update_cart_total_price
    cart.update(total_price: cart.calculate_total_price)
  end

  def product
    @product ||= Product.find(product_id)
  end

  def cart_products
    @cart_products ||= CartProduct.where(cart_id: cart.id, product_id: product_id)
  end
end
