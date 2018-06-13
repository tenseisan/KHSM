FactoryBot.define do
  factory :user do
    name {"Жора_#{rand(9999)}"}

    sequence(:email) {|n| "mail_#{n}@mymail.com"}

    is_admin false
    balance 0

    after(:build) {|u| u.password_confirmation = u.password = "123123"}
    end
  end