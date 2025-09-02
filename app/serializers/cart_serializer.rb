class CartSerializer < ActiveModel::Serializer
  attributes :id

  attribute :products do
    object.cart_products.map do |cart_product|
      {
        id: cart_product.product.id,
        name: cart_product.product.name,
        quantity: cart_product.quantity,
        unit_price: cart_product.product.price,
        total_price: cart_product.quantity * cart_product.product.price
      }
    end
  end

  attribute :total_price do
    object.total_price
  end
end