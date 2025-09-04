require 'rails_helper'

RSpec.describe CartService do
  let!(:cart) { create(:cart) }
  let!(:product) { create(:product) }
  let(:product_id) { product.id }
  let(:quantity) { 1 }

  subject(:service) { described_class.new(cart, product_id, quantity) }

  describe '#add_product' do
    context 'when the product is not yet in the cart' do
      it 'creates a new item in the cart (CartProduct)' do
        expect { service.add_product }.to change(CartProduct, :count).by(1)
        expect(cart.cart_products.last.quantity).to eq(1)
      end
    end

    context 'when the product is already in the cart' do
      let!(:cart_product) { create(:cart_product, cart: cart, product: product, quantity: 3) }
      let(:quantity) { 2 }

      it 'increments the quantity of the existing product' do
        expect { service.add_product }.to change { cart_product.reload.quantity }.from(3).to(5)
      end
    end

    context 'when the cart was abandoned' do
      let!(:cart) { create(:cart, :abandoned) }

      it 'marks the cart as open' do
        expect { service.add_product }.to change { cart.reload.status }.from('abandoned').to('open')
      end
    end

    context 'when the product does not exist' do
      let(:product_id) { -1 }

      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { service.add_product }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the quantity is less than 1' do
      let(:quantity) { 0 }

      it 'raises an ArgumentError' do
        expect { service.add_product }.to raise_error(ArgumentError, 'Quantity must be greater than zero')
      end
    end

    context 'when the cart is completed' do
      let(:cart) { create(:cart, :completed) }

      it 'raises a StandardError' do
        expect { service.add_product }.to raise_error(StandardError, 'Cannot add products to a completed or expired cart')
      end
    end

    context 'when the cart is expired' do
      let(:cart) { create(:cart, :expired) }

      it 'raises a StandardError' do
        expect { service.add_product }.to raise_error(StandardError, 'Cannot add products to a completed or expired cart')
      end
    end
  end

  describe '#remove_product' do
    let!(:cart_product) { create(:cart_product, cart: cart, product: product, quantity: 5) }

    context 'when the quantity to be removed is less than the quantity in the cart' do
      let(:quantity) { 2 }

      it 'decreases the product quantity' do
        expect { service.remove_product }.to change { cart_product.reload.quantity }.from(5).to(3)
      end

      it 'does not remove the item from the cart' do
        expect { service.remove_product }.not_to change(CartProduct, :count)
      end
    end

    context 'when the quantity to be removed is equal to the quantity in the cart' do
      let(:quantity) { 5 }

      it 'removes the item from the cart completely' do
        expect { service.remove_product }.to change(CartProduct, :count).by(-1)
      end
    end

    context 'when the product to be removed does not exist' do
      let(:product_id) { -1 }

      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { service.remove_product }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
