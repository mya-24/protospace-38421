FactoryBot.define do
  factory :prototype do
    title        {Faker::Lorem.sentence}
    catch_copy   {Faker::Lorem.sentence}
    concept      {Faker::Lorem.sentence}
    association :user

    after(:build) do |i|
      i.image.attach(io: File.open('public/images/test.png'), filename: 'test.png')
    end
    
  end
end
