FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    status { :open }

    trait :abandoned do
      status { :abandoned }
      updated_at { 4.hours.ago }
    end

    trait :expired do
      status { :expired }
      updated_at { 8.days.ago }
    end
  end
end
