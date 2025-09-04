FactoryBot.define do
  factory :cart_product do
    association :cart
    association :product

    quantity { 1 }
  end
end
