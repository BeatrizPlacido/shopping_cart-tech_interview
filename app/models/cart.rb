class Cart < ApplicationRecord
  include AASM

  INACTIVITY_THRESHOLD = 3.hours
  EXPIRED_THRESHOLD = 7.days

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_products
  has_many :products, through: :cart_products

  aasm column: 'status' do
    state :open, initial: true
    state :abandoned
    state :completed
    state :expired

    event :mark_as_abandoned, guard: :inactive? do
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

  scope :in_inactive_threshold, -> { where('last_interaction_at < ?', INACTIVITY_THRESHOLD.ago) }
  scope :in_expired_threshold, -> { where('last_interaction_at < ?', EXPIRED_THRESHOLD.ago) }

  def update_total_price
    update!(total_price: calculate_total_price)
  end

  def calculate_total_price
    return 0 if cart_products.blank?

    cart_products.includes(:product).sum do |cart_product|
      cart_product.quantity * cart_product.product.price
    end
  end

  def update_last_interaction
    update!(last_interaction_at: Time.current)
  end

  def remove_if_abandoned
    return unless abandoned_cart?

    cart_products.destroy_all
    self.destroy!
  end

  def inactive?
    last_interaction_at < INACTIVITY_THRESHOLD.ago
  end

  def abandoned_cart?
    last_interaction_at < EXPIRED_THRESHOLD.ago
  end
end
