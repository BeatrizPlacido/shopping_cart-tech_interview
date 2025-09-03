class CartService
  def initialize(current_cart, product_id, quantity = 1)
    @cart = current_cart
    @product_id = product_id
    @quantity = quantity
  end

  def add_product
    raise ActiveRecord::RecordNotFound, "Product with ID=#{product_id} not found" if @product.blank?
    raise ArgumentError, 'Quantity must be greater than zero' if quantity.to_i < 1
    raise StandardError, 'Cannot add products to a completed or expired cart' if cart.completed? || cart.expired?

    create_cart_product
    cart.mark_as_open if cart.abandoned?

    cart.reload
  end

  def remove_product
    raise ActiveRecord::RecordNotFound, "Product with ID=#{product_id} not found" if @product.blank?

    remove_product_from_cart
    cart.mark_as_open if cart.abandoned?

    cart.reload
  end

  private

  attr_reader :cart, :product_id, :quantity

  def create_cart_product
    return CartProduct.create!(cart:, product:, quantity:) if cart_product.blank?

    cart_product.quantity += quantity.to_i
    cart_product.save
  end

  def remove_product_from_cart
    cart_product.quantity -= quantity.to_i
    cart_product.save
    cart_product.destroy if cart_product.quantity.zero?
  end

  def product
    @product ||= Product.find(product_id)
  end

  def cart_product
    @cart_product ||= CartProduct.find_by(cart_id: cart.id, product_id:)
  end
end
