class MarkCartAsAbandonedJob
  include Sidekiq::Job

  INACTIVITY_THRESHOLD = 3.hours
  EXPIRED_THRESHOLD = 7.days

  def perform
    mark_inactive_carts_as_abandoned
    mark_as_expired_old_abandoned_carts
  end

  private

  def mark_inactive_carts_as_abandoned
    abandoned_candidate_carts = Cart.where(status: 'open')
                                    .where('updated_at < ?', INACTIVITY_THRESHOLD.ago)

    return if abandoned_candidate_carts.blank?

    abandoned_candidate_carts.update_all(status: 'abandoned', updated_at: Time.current)
  end

  def mark_as_expired_old_abandoned_carts
    expired_candidate_carts = Cart.where(status: 'abandoned')
                                  .where('updated_at < ?', EXPIRED_THRESHOLD.ago)

    return if expired_candidate_carts.blank?

    expired_candidate_carts.update_all(status: 'expired', updated_at: Time.current)
  end
end
