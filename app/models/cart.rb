class Cart < ApplicationRecord
  include AASM

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_products
  has_many :products, through: :cart_products

  aasm column: 'status' do
    state :open, initial: true
    state :abandoned
    state :completed
    state :expired

    event :abandon, guard: :inactive? do
      transitions from: :open, to: :abandoned
    end

    event :mark_as_open do
      transitions from: :abandoned, to: :open
    end

    event :complete do
      transitions from: :open, to: :completed
    end

    event :expire do
      transitions from: :abandoned, to: :expired
    end
  end

  def update_total_price
    update!(total_price: total_price)
  end

  def total_price
    return 0 if cart_products.blank?

    cart_products.includes(:product).sum do |cart_product|
      cart_product.quantity * cart_product.product.price
    end
  end

  private

  def inactive?
    updated_at < 3.hour.ago
  end
end
