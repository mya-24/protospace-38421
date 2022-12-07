require 'rails_helper'

RSpec.describe "Prototypes", type: :system do
  before do
    @user = FactoryBot.build(:user)
    @another = FactoryBot.build(:user)

    @prototype_1 = FactoryBot.build(:prototype, user:@user)
    @prototype_2 = FactoryBot.build(:prototype, user:@another)

    @comment = FactoryBot.build(:comment, user:@another, prototype:@prototype_1)
  end


  context '投稿機能チェック' do
    it '必要な情報が入力されていれば投稿でき、投稿した情報が正しく表示されている' do
      #ログインしていない場合、投稿ページへ遷移できない
      visit new_prototype_path
      expect(current_path).to eq(new_user_session_path)
      #ログイン状態のユーザーだけが、投稿ページへ遷移できること
      @user.save
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click
      visit new_prototype_path
      expect(current_path).to eq(new_prototype_path)

      #投稿に必要な情報が入力されていない場合は、投稿できずにそのページに留まること
      fill_in 'prototype_title', with: ''
      fill_in 'prototype_catch_copy', with: @prototype_1.catch_copy
      fill_in 'prototype_concept', with: @prototype_1.concept

      image_path = Rails.root.join('public/images/test.png')
      attach_file('prototype[image]', image_path)

      expect{
        find('input[name="commit"]').click
      }.to change{Prototype.count}.by(0)
      expect(current_path).to eq(prototypes_path)

      #バリデーションによって投稿ができず、そのページに留まった場合でも、入力済みの項目（画像以外）は消えないこと
      expect(
        find('#prototype_catch_copy').value
      ).to eq(@prototype_1.catch_copy)
      expect(
        find('#prototype_concept').value
      ).to eq(@prototype_1.concept)
      
      #正しく投稿できた場合は、トップページへ遷移すること
      fill_in 'prototype_title', with: @prototype_1.title

      image_path = Rails.root.join('public/images/test.png')
      attach_file('prototype[image]', image_path)

      expect{
        find('input[name="commit"]').click
      }.to change{Prototype.count}.by(1)
      expect(current_path).to eq(root_path)

      #投稿した情報は、トップページに表示されること
      #トップページに表示される投稿情報は、プロトタイプ毎に、画像・プロトタイプ名・キャッチコピー・投稿者の名前の、4つの情報について表示できること
      expect(page).to have_content(@prototype_1.title)
      expect(page).to have_content(@prototype_1.catch_copy)
      expect(page).to have_content("by #{@user.name}")
      #画像が表示されており、画像がリンク切れなどになっていないこと
      expect(page).to have_selector(".card__img")
    end
  end


  context '詳細ページ機能チェック' do
    it 'プロトタイプ詳細ページ遷移チェック' do
      @user.save
      @prototype_1.save
      
      #ログアウト状態で一覧表示されている画像をクリックすると該当プロトタイプの詳細ページへ遷移する
      visit root_path
      find('.card__img').click
      expect(current_path).to eq(prototype_path(@prototype_1))

      #ログアウト状態で一覧表示されているプロトタイプ名をクリックすると該当プロトタイプの詳細ページへ遷移する
      visit root_path
      find_link((@prototype_1.title), href: prototype_path(@prototype_1)).click
      expect(current_path).to eq(prototype_path(@prototype_1))

      #ログイン状態で一覧表示されている画像をクリックすると該当プロトタイプの詳細ページへ遷移する
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click
      
      find('.card__img').click
      expect(current_path).to eq(prototype_path(@prototype_1))

      #ログイン状態で一覧表示されているプロトタイプ名をクリックすると該当プロトタイプの詳細ページへ遷移する
      visit root_path
      find_link((@prototype_1.title), href: prototype_path(@prototype_1)).click
      expect(current_path).to eq(prototype_path(@prototype_1))
    end


    it 'ログイン状態のユーザーにのみ「編集」「削除」のリンクが存在すること' do
      #ログアウト状態だとリンクが存在しない
      @user.save
      @prototype_1.save

      #詳細ページに移動、編集と削除のリンク確認
      visit prototype_path(@prototype_1)
      expect(page).to have_no_link('編集する', href:(edit_prototype_path(@prototype_1)))
      expect(page).to have_no_link('削除する', href:(prototype_path(@prototype_1)))

      #ログインしたらリンクが存在する
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      #詳細ページに移動、編集と削除のリンク確認
      visit prototype_path(@prototype_1)
      expect(page).to have_link('編集する', href:(edit_prototype_path(@prototype_1)))
      expect(page).to have_link('削除する', href:(prototype_path(@prototype_1)))
    end

    it 'ログイン・ログアウトに関わらずプロダクト情報が表示されていること' do
      @user.save
      @prototype_1.save
      
      #ログアウト状態
      visit root_path
      expect(page).to have_content(@prototype_1.title)
      expect(page).to have_content(@prototype_1.catch_copy)
      expect(page).to have_content("by #{@user.name}")
      expect(page).to have_selector(".card__img")


      #ログイン状態
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      #情報確認
      expect(page).to have_content(@prototype_1.title)
      expect(page).to have_content(@prototype_1.catch_copy)
      expect(page).to have_content("by #{@user.name}")
      expect(page).to have_selector(".card__img")
    end
  end

  context 'プロトタイプ編集機能チェック' do
    it '投稿に必要な情報を入力するとプロトタイプの編集ができる' do
      #ログイン状態のユーザーに限り、自身の投稿したプロトタイプの詳細ページから編集ボタンをクリックすると、編集ページへ遷移できること
      @user.save
      @prototype_1.save
      @prototype_2.save

      #ログインしていない状態で編集画面に遷移しようとすると出来ない
      visit edit_prototype_path(@prototype_1)
      expect(current_path).to eq(new_user_session_path)

      #userログイン
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      #ログイン者と投稿者が一致しない場合、編集画面に遷移しようとするとできない
      visit edit_prototype_path(@prototype_2)
      expect(current_path).to eq(prototypes_path)

      #ログイン者と投稿者が一致する場合、編集ページで編集できる
      visit edit_prototype_path(@prototype_1)

      #既に登録されている情報は値が保持されていることを確認
      expect(
        find('#prototype_title').value
      ).to eq(@prototype_1.title)
      expect(
        find('#prototype_catch_copy').value
      ).to eq(@prototype_1.catch_copy)
      expect(
        find('#prototype_concept').value
      ).to eq(@prototype_1.concept)

      #何も編集せずに保存ボタンクリック
      find('input[name="commit"]').click
      #保存されたら詳細ページに戻る
      expect(current_path).to eq(prototype_path(@prototype_1))
      #画像が消えていないこと
      expect(page).to have_selector ".prototype__image"

      visit edit_prototype_path(@prototype_1)
      #空の入力欄がある場合、編集できずそのページに止まる
      fill_in 'prototype_title', with: ''
      find('input[name="commit"]').click
      expect(current_path).to eq(edit_prototype_path(@prototype_1))
      
      #保存ができなかった場合でも、既に登録されている情報は値が保持されていることを確認
      expect(
        find('#prototype_catch_copy').value
      ).to eq(@prototype_1.catch_copy)
      expect(
        find('#prototype_concept').value
      ).to eq(@prototype_1.concept)
    end
  end

  context 'プロトタイプ削除機能チェック' do
    it 'ログイン中のユーザーのみ、自身の投稿を削除できる' do
      @user.save
      @prototype_1.save
      @prototype_2.save
  
      #ログインしていない状態では削除ボタンが見られない
      visit prototype_path(@prototype_1)
      expect(page).to have_no_link('削除する', href:(prototype_path(@prototype_1)))

      #ログイン者と投稿者が一致していない状態では削除ボタンが見られない
      visit new_user_session_path
      fill_in 'user_email', with: @another.email
      fill_in 'user_password', with: @another.password
      find('input[name="commit"]').click

      visit prototype_path(@prototype_1)
      expect(page).to have_no_link('削除する', href:(prototype_path(@prototype_1)))
      
      #ログイン者と投稿者が一致した状態で削除ボタンをクリックすると記事削除される
      find_link('ログアウト', href: destroy_user_session_path).click
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      visit prototype_path(@prototype_1)
      expect{
        find_link('削除する', href:(prototype_path(@prototype_1))).click
      }.to change{Prototype.count}.by(-1)

      #削除が完了すればトップページに戻る
      expect(current_path).to eq(root_path)
    end
  end
  
  context 'コメント投稿機能チェック' do
    it 'ログイン中のユーザーのみ、詳細ページにコメント投稿欄が表示される' do
      @user.save
      @prototype_1.save

      #ログインしていなければコメント投稿欄は表示されない
      visit prototype_path(@prototype_1)
      expect(page).to have_no_content "コメント"

      #ログインしていればコメント投稿欄は表示される
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      visit prototype_path(@prototype_1)
      expect(page).to have_content "コメント"

      #コメントが空では入力できない
      fill_in 'comment_content', with:''
      expect{
        find('input[name="commit"]').click
      }.to change{Comment.count}.by(0)

      #正しく入力すると投稿でき、詳細ページに戻る
      fill_in 'comment_content', with:'sample'
      expect{
        find('input[name="commit"]').click
      }.to change{Comment.count}.by(1)

      expect(current_path).to eq(prototype_path(@prototype_1))

      #詳細ページにコメント内容とコメント者が表示されている
      expect(page).to have_content('sample')
      expect(page).to have_content(@user.name)
    end
  end
  
  context 'ユーザー詳細ページ機能チェック' do
    it 'ログイン・ログアウトの状態に関わらず、各ページのユーザー名をクリックするとユーザー詳細ページへ遷移する' do
      @user.save
      @another.save
      @prototype_1.save
      @comment.save

      #ログアウト状態
      #トップページ投稿一覧の「by XX」から遷移
      visit root_path
      find_link("by #{@user.name}").click
      expect(current_path).to eq(user_path(@user))

      #詳細ページの投稿者名から遷移
      visit prototype_path(@prototype_1)
      find_link("#{@user.name}").click
      expect(current_path).to eq(user_path(@user))

      #ユーザーの詳細画面には名前、プロフィール、所属、役職とプロトタイプ一覧が表示されていること
      expect(page).to have_content("#{@user.name}")
      expect(page).to have_content("#{@user.profile}")
      expect(page).to have_content("#{@user.occupation}")
      expect(page).to have_content("#{@user.position}")
      expect(page).to have_content("#{@user.name}さんのプロトタイプ")
      #詳細ページのコメントはログアウト状態では表示されないので割愛

      #ログイン状態
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      #トップページ投稿一覧の「by XX」から遷移
      visit root_path
      find_link("by #{@user.name}").click
      expect(current_path).to eq(user_path(@user))
      
      #詳細ページの投稿者名から遷移
      visit prototype_path(@prototype_1)
      find_link("#{@user.name}").click
      expect(current_path).to eq(user_path(@user))

      #詳細ページのコメント者名から遷移
      visit prototype_path(@prototype_1)
      find_link("#{@another.name}").click
      expect(current_path).to eq(user_path(@another))

      #ユーザーの詳細画面には名前、プロフィール、所属、役職とプロトタイプ一覧が表示されていること
      expect(page).to have_content("#{@another.name}")
      expect(page).to have_content("#{@another.profile}")
      expect(page).to have_content("#{@another.occupation}")
      expect(page).to have_content("#{@another.position}")
      expect(page).to have_content("#{@another.name}さんのプロトタイプ")
    end
  end

  context 'その他' do
    it 'ログアウト状態のユーザーは新規投稿、投稿編集、投稿削除ページに遷移できない（ログインページに遷移する）' do
      @prototype_1.save

      #新規投稿ページ
      visit new_prototype_path
      expect(current_path).to eq(new_user_session_path)

      #投稿編集ページ
      visit edit_prototype_path(@prototype_1)
      expect(current_path).to eq(new_user_session_path)

      #投稿削除ページ
      delete prototype_path(@prototype_1)
      expect(current_path).to eq(new_user_session_path)
    end

    it 'ログアウト状態のユーザーでもトップ、投稿詳細、ユーザー詳細、ユーザー新規登録、ログインページには遷移できる' do
      @user.save
      @prototype_1.save

      #トップページ
      visit root_path
      expect(current_path).to eq(root_path)

      #投稿詳細ページ
      visit prototype_path(@prototype_1)
      expect(current_path).to eq(prototype_path(@prototype_1))

      #ユーザー詳細ページ
      visit user_path(@user)
      expect(current_path).to eq(user_path(@user))

      #ユーザー新規登録ページ
      visit new_user_registration_path
      expect(current_path).to eq(new_user_registration_path)

      #ログインページ
      visit new_user_session_path
      expect(current_path).to eq(new_user_session_path)
    end

    it 'ログイン中のユーザーであっても、他のユーザーの投稿編集ページのURLに直接遷移しようとすると、トップページにリダイレクトされる' do
      @user.save
      @prototype_2.save

      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click

      visit edit_prototype_path(@prototype_2)
      expect(current_path).to eq(prototypes_path)
    end
  end


end
