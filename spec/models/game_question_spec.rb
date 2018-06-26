require 'rails_helper'
require 'game_help_generator'

RSpec.describe GameQuestion, type: :model do

  let(:game_question) { FactoryBot.create(:game_question, a: 1, b: 2, c: 3, d: 4) }

  context 'game status' do
    it 'correct .variants' do
      expect(game_question.variants).to eq(
                                        {
                                        'a' => game_question.question.answer1,
                                        'b' => game_question.question.answer2,
                                        'c' => game_question.question.answer3,
                                        'd' => game_question.question.answer4
                                        }
                                        )
    end

    it 'correct .answer_correct?' do
      expect(game_question.answer_correct?('a')).to be_truthy
    end

    it 'correct .correct_answer_key' do
      expect(game_question.correct_answer_key).to eq("a")
    end

    it 'correct .level & .text delegates' do
      expect(game_question.text).to eq(game_question.question.text)
      expect(game_question.level).to eq(game_question.question.level)
    end

    it 'correct .help_hash' do
      expect(game_question.help_hash).to eq({})

      game_question.help_hash[:some_key1] = 'blabla1'
      game_question.help_hash['some_key2'] = 'blabla2'

      expect(game_question.save).to be_truthy

      gq = GameQuestion.find(game_question.id)

      expect(gq.help_hash).to eq({some_key1: 'blabla1', 'some_key2' => 'blabla2'})
    end
  end

  # Группа тестов на помощь игроку
  context 'user helpers' do
    it 'correct audience_help' do
      # сначала убедимся, в подсказках пока нет нужного ключа
      expect(game_question.help_hash).not_to include(:audience_help)
      # вызовем подсказку
      game_question.add_audience_help

      # проверим создание подсказки
      expect(game_question.help_hash).to include(:audience_help)

      # мы не можем знать распределение, но может проверить хотя бы наличие нужных ключей
      ah = game_question.help_hash[:audience_help]
      expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
    end

    it 'correct fifty_fifty' do
      # сначала убедимся, в подсказках пока нет нужного ключа
      expect(game_question.help_hash).not_to include(:fifty_fifty)
      # вызовем подсказку
      game_question.add_fifty_fifty

      # проверим создание подсказки
      expect(game_question.help_hash).to include(:fifty_fifty)
      ff = game_question.help_hash[:fifty_fifty]

      expect(ff).to include('a') # должен остаться правильный вариант
      expect(ff.size).to eq 2 # всего должно остаться 2 варианта
    end

    it 'correct friend_call' do
      expect(game_question.help_hash).not_to include(:friend_call)
      game_question.add_friend_call

      fc = game_question.help_hash[:friend_call]

      expect(fc).to be_a(String)
      expect(fc).to include('A').or include('B').or include('C').or include('D')
    end
  end
end
