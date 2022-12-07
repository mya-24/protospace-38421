FactoryBot.define do
  factory :comment do
    content   {Faker::Lorem.word}
    association :user
    association :prototype
  end
end
