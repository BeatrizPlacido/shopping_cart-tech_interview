RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:cart_products) }
    it { should have_many(:carts).through(:cart_products) }
  end
end
