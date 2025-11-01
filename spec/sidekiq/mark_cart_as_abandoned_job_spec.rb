RSpec.describe AbandonedCartHandlerJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    context 'when marking open carts as abandoned' do
      let!(:inactive_open_cart) { create(:cart, status: 'open', last_interaction_at: 4.hours.ago) }
      let!(:active_open_cart) { create(:cart, status: 'open', last_interaction_at: 1.hour.ago) }
      let!(:completed_cart) { create(:cart, status: 'completed', last_interaction_at: 5.hours.ago) }

      it 'updates only the inactive open carts to abandoned' do
        job.perform
        expect(inactive_open_cart.reload.status).to eq('abandoned')
        expect(active_open_cart.reload.status).to eq('open')
        expect(completed_cart.reload.status).to eq('completed')
      end
    end
  end
end
