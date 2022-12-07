require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    @user = FactoryBot.build(:user)
  end

  context 'ログインができる' do
    it '必要な情報を入力すればログインができ、トップページに遷移／ログアウトできる' do
      #トップページへ遷移
      visit root_path
      #ログアウト状態では、ヘッダーに「新規登録」「ログイン」のリンクが存在すること
      expect(page).to have_link '新規登録', href: new_user_registration_path
      expect(page).to have_link 'ログイン', href: new_user_session_path

      #フォームに適切な値が入力されていない状態では、新規登録・ログインはできず、そのページに留まること（新規登録/ログイン）
      #新規登録
      visit new_user_registration_path
      fill_in 'user_email', with: ''
      fill_in 'user_password', with: @user.password
      fill_in 'user_password_confirmation', with: @user.password
      fill_in 'user_name', with: @user.name
      fill_in 'user_profile', with: @user.profile
      fill_in 'user_occupation', with: @user.occupation
      fill_in 'user_position', with: @user.position
      find('input[name="commit"]').click
      expect(current_path).to eq(user_registration_path)

      #ログイン
      visit new_user_session_path
      fill_in 'user_email', with: ''
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click
      expect(current_path).to eq(user_session_path)

      #必要な情報を入力すると、ログインができること
      @user.save
      visit new_user_session_path
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: @user.password
      find('input[name="commit"]').click
      expect(current_path).to eq(root_path)

      #ログイン状態では、ヘッダーに「ログアウト」「New Proto」のリンクが存在すること
      expect(page).to have_link 'ログアウト', href: destroy_user_session_path
      expect(page).to have_link 'New Proto', href: new_prototype_path

      #ログイン状態では、トップページに「こんにちは、〇〇さん」とユーザー名が表示されていること
      expect(page).to have_content("こんにちは、#{@user.name}さん")

      #トップページから、ログアウトができること
      find_link('ログアウト', href: destroy_user_session_path).click
      expect(current_path).to eq(root_path)
      expect(page).to have_link 'ログイン', href: new_user_session_path
      
    end
  end

end
