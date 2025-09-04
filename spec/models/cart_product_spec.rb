RSpec.describe CartProduct, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'callbacks' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    describe '#after_save' do
      it 'calls update_cart_total on its cart after creation' do
        expect(cart).to receive(:update_total_price)
        create(:cart_product, cart: cart, product: product)
      end

      it 'calls update_cart_total on its cart after update' do
        cart_product = create(:cart_product, cart: cart, product: product)
        expect(cart_product.cart).to receive(:update_total_price)
        cart_product.update(quantity: 3)
      end
    end

    describe '#after_destroy' do
      it 'calls update_cart_total on its cart after being destroyed' do
        cart_product = create(:cart_product, cart: cart, product: product)
        expect(cart_product.cart).to receive(:update_total_price)
        cart_product.destroy
      end
    end
  end
end
