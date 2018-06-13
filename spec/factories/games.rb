FactoryBot.define do
  factory :game do
    association :user

    finished_at nil
    current_level 0
    is_failed false
    prize 0

    factory :game_with_questions do
      after(:build) { |game|
        15.times do |item|
          question = create(:question, level: item)
          create(:game_question, game: game, question: question)
        end
      }
    end

  end
end