RSpec.describe MarkCartAsAbandonedJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    context 'when marking open carts as abandoned' do
      let!(:inactive_open_cart) { create(:cart, status: 'open', updated_at: 4.hours.ago) }
      let!(:active_open_cart) { create(:cart, status: 'open', updated_at: 1.hour.ago) }
      let!(:completed_cart) { create(:cart, status: 'completed', updated_at: 5.hours.ago) }

      it 'updates only the inactive open carts to abandoned' do
        job.perform
        expect(inactive_open_cart.reload.status).to eq('abandoned')
        expect(active_open_cart.reload.status).to eq('open')
        expect(completed_cart.reload.status).to eq('completed')
      end
    end

    context 'when marking abandoned carts as expired' do
      let!(:old_abandoned_cart) { create(:cart, status: 'abandoned', updated_at: 8.days.ago) }
      let!(:recent_abandoned_cart) { create(:cart, status: 'abandoned', updated_at: 1.day.ago) }

      it 'updates only the old abandoned carts to expired' do
        job.perform
        expect(old_abandoned_cart.reload.status).to eq('expired')
        expect(recent_abandoned_cart.reload.status).to eq('abandoned')
      end
    end

    context 'when running both steps together' do
      let!(:old_open_cart) { create(:cart, status: 'open', updated_at: 10.days.ago) }

      it 'abandons the old open cart but does not expire it in the same run' do
        job.perform
        reloaded_cart = old_open_cart.reload
        expect(reloaded_cart.status).to eq('abandoned')
        expect(reloaded_cart.updated_at).to be_after(1.minute.ago)
      end
    end
  end
end
