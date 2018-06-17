require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

RSpec.describe GamesController, type: :controller do

  # обычный пользователь
  let(:user) { FactoryBot.create(:user) }
  # админ
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context 'usual user' do

  before(:each) { sign_in user }

  # проверка, что пользовтеля посылают из чужой игры
    it '#show alien game' do
      # создаем новую игру, юзер не прописан, будет создан фабрикой новый
      alien_game = FactoryBot.create(:game_with_questions)

      # пробуем зайти на эту игру текущий залогиненным user
      get :show, id: alien_game.id

      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    # юзер берет деньги
    it 'takes money' do
      # вручную поднимем уровень вопроса до выигрыша 200
      game_w_questions.update_attribute(:current_level, 2)


      put :take_money, id: game_w_questions.id
      game = assigns(:game)

      expect(assigns(:game)).to eq(game)
      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(200)

      # пользователь изменился в базе, надо в коде перезагрузить!
      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

  it 'try to create second game' do
    # убедились что есть игра в работе
    expect(game_w_questions.finished?).to be_falsey

    # отправляем запрос на создание, убеждаемся что новых Game не создалось
    expect { post :create }.to change(Game, :count).by(0)

    game = assigns(:game) # вытаскиваем из контроллера поле @game
    expect(game).to be_nil

    # и редирект на страницу старой игры
    expect(response).to redirect_to(game_path(game_w_questions))
    expect(flash[:alert]).to be
  end
  end

  context 'anonym user' do
    it 'kick from #show' do
      # вызываем экшен
      get :show, id: game_w_questions.id
      # проверяем ответ
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    it 'kick from #create' do
      post :create

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #answer' do
      put :answer, id: game_w_questions.id, params: {letter: 'd'}

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it 'kick from #take_money' do
      put :take_money, id: game_w_questions.id

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end
  end

end