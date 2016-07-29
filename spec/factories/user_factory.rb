FactoryGirl.define do
  factory :user do
    admin false
    after(:create) do |user, _|
      create(:oauth_credentials, user: user)
    end
  end
end
