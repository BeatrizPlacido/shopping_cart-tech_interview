RSpec.describe Cart, type: :model do
  subject(:cart) { create(:cart) }

  describe 'validations' do
    it { should validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:cart_products) }
    it { should have_many(:products).through(:cart_products) }
  end

  describe 'state machine' do
    it 'starts with the "open" state' do
      expect(cart).to have_state(:open)
      expect(cart.open?).to be(true)
    end

    describe 'event: :mark_as_abandoned' do
      context 'when the cart is inactive (updated more than 3 hours ago)' do
        let(:inactive_cart) { create(:cart, status: 'open', last_interaction_at: 4.hours.ago) }

        it 'transitions from :open to :abandoned' do
          expect { inactive_cart.mark_as_abandoned! }.to change(inactive_cart, :status).from('open').to('abandoned')
        end
      end

      context 'when the cart is active (updated recently)' do
        let(:active_cart) { create(:cart, status: 'open', last_interaction_at: 1.hour.ago) }

        it 'does not transition and raises an error' do
          expect { active_cart.mark_as_abandoned! }.to raise_error(AASM::InvalidTransition)
        end
      end
    end

    describe 'event: :mark_as_open' do
      let(:abandoned_cart) { create(:cart, status: 'abandoned') }

      it 'transitions from :abandoned to :open' do
        expect { abandoned_cart.mark_as_open! }.to change(abandoned_cart, :status).from('abandoned').to('open')
      end
    end

    describe 'event: :complete' do
      it 'transitions from :open to :completed' do
        expect { cart.complete! }.to change(cart, :status).from('open').to('completed')
      end
    end

    describe 'event: :expire' do
      let(:abandoned_cart) { create(:cart, status: 'abandoned') }

      it 'transitions from :abandoned to :expired' do
        expect { abandoned_cart.expire! }.to change(abandoned_cart, :status).from('abandoned').to('expired')
      end
    end
  end

  describe 'instance methods' do
    describe '#total_price' do
      context 'when cart is empty' do
        it 'returns 0' do
          expect(cart.total_price).to eq(0)
        end
      end

      context 'when cart has products' do
        let(:product1) { create(:product, price: 100.0) }
        let(:product2) { create(:product, price: 50.0) }

        before do
          create(:cart_product, cart: cart, product: product1, quantity: 2) # 2 * 100 = 200
          create(:cart_product, cart: cart, product: product2, quantity: 3) # 3 * 50  = 150
        end

        it 'calculates the correct total price' do
          expect(cart.reload.total_price).to eq(350.0)
        end
      end
    end

    describe '#inactive?' do
      context 'when updated more than 3 hours ago' do
        it 'returns true' do
          travel_to 4.hours.ago do
            cart.touch
          end
          expect(cart.inactive?).to be(true)
        end
      end

      context 'when updated recently' do
        it 'returns false' do
          cart.touch
          expect(cart.inactive?).to be(false)
        end
      end
    end
  end
  # default tests provided
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
