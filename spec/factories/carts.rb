FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    status { :open }
    last_interaction_at { Time.current }

    trait :abandoned do
      status { :abandoned }
      updated_at { 4.hours.ago }
    end

    trait :expired do
      status { :expired }
      updated_at { 8.days.ago }
    end

    trait :completed do
      status { :completed }
    end
  end
end
