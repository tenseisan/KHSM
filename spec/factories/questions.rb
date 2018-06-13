FactoryBot.define do
  factory :question do
    answer1 {"#{rand(2000)}"}
    answer2 {"#{rand(2000)}"}
    answer3 {"#{rand(2000)}"}
    answer4 {"#{rand(2000)}"}

    sequence(:text) {|n| "Сколько еще лет Путин будет президентом? #{n}"}
    sequence(:level) {|n| n % 15}
  end
end