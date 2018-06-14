require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do

  let(:user) { FactoryBot.create(:user) }

  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'game factory' do
    it 'game_create_for_user! new correct game' do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(change(GameQuestion, :count).by(15)
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq (15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'correct answer continue game' do

      l = game_w_questions.current_level
      q = game_w_questions.current_game_question

      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(l + 1)

      expect(game_w_questions.current_game_question).not_to eq q

      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it 'take_money! finishes the game' do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)

      game_w_questions.take_money!

      prize = game_w_questions.prize
      expect(prize).to be > 0

      expect(game_w_questions.status).to eq :money
      expect(game_w_questions.finished?).to be_truthy
      expect(user.balance).to eq prize
    end
  end


  # Задание 61-6

  describe '#current_game_question' do
    it 'should return current unanswered question' do
      expect(game_w_questions.current_game_question).to eq game_w_questions.game_questions[0]

      game_w_questions = FactoryBot.create(:game_with_questions, current_level: 5)
      expect(game_w_questions.current_game_question).to eq game_w_questions.game_questions[5]
    end
  end

  describe '#previous_level' do
    it 'should return previous level number of game' do
     expect(game_w_questions.previous_level).to eq -1

     game_w_questions = FactoryBot.create(:game_with_questions, current_level: 5)
     expect(game_w_questions.previous_level).to eq 4
    end
  end

  # Задание 61-7

  describe '#answer_current_question!' do
    it 'return true when correct answer' do
      right_answer = game_w_questions.answer_current_question!('d')

      expect(right_answer).to eq true
    end

    it 'return false when incorrect answer' do
      right_answer = game_w_questions.answer_current_question!('c')

      expect(right_answer).to eq false
    end

    it 'last question' do
      game_w_questions = FactoryBot.create(:game_with_questions, current_level: 14)
      game_w_questions.answer_current_question!('d')

      expect(game_w_questions.prize).to eq 1000000
    end

    it 'timeout' do
      game_w_questions.answer_current_question!('d')

      expect(game_w_questions.is_failed).to eq false
    end
  end

  context '.status' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end
end
