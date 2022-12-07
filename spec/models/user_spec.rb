require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe 'ユーザー新規登録' do
    context '登録できる' do
      it 'メールアドレス、パスワード、名前、プロフィール、所属、役職が揃っていれば登録できる' do
        expect(@user).to be_valid
      end
    end

    context '登録できない' do
      it 'メールアドレスがないと登録できない' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Email can't be blank")
      end
      it 'メールアドレスには一意性がある' do
        @user.save
        another = FactoryBot.build(:user, email:@user.email)
        another.valid?
        expect(another.errors.full_messages).to include("Email has already been taken")
      end
      it 'メールアドレスには「＠」を含んでないと登録できない' do
        @user.email = 'testmail'
        @user.valid?
        expect(@user.errors.full_messages).to include("Email is invalid")
      end
      it 'パスワードがないと登録できない' do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Password can't be blank")
      end
      it 'パスワードが6文字以上でないと登録できない' do
        @user.password = '12345'
        @user.password_confirmation = '12345'
        @user.valid?
        expect(@user.errors.full_messages).to include("Password is too short (minimum is 6 characters)")
      end
      it '確認用パスワードが入力されていないと登録できない' do
        @user.password_confirmation = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
      it 'パスワードが確認用パスワードと一致しないと登録できない' do
        @user.password = '123456'
        @user.password_confirmation = '234567'
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
      it 'ユーザー名がないと登録できない' do
        @user.name = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Name can't be blank")
      end
      it 'プロフィールの入力がないと登録できない' do
        @user.profile = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Profile can't be blank")
      end
      it '所属の入力がないと登録できない' do
        @user.occupation = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Occupation can't be blank")
      end
      it '役職の入力がないと登録できない' do
        @user.position = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Position can't be blank")
      end
    end
  end
end
