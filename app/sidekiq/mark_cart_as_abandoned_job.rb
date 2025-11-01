class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    mark_inactive_carts_as_abandoned
    remove_abandoned_carts
  end

  private

  def mark_inactive_carts_as_abandoned
    abandoned_candidate_carts = Cart.in_inactive_threshold.where(status: 'open')

    return if abandoned_candidate_carts.blank?

    abandoned_candidate_carts.each { |cart| cart.mark_as_abandoned! }
  end

  def remove_abandoned_carts
    expired_candidate_carts = Cart.where(status: 'abandoned')

    return if expired_candidate_carts.blank?

    expired_candidate_carts.each{ |cart| cart.remove_if_abandoned }
  end
end
