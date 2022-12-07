require 'rails_helper'

RSpec.describe Prototype, type: :model do
  before do
    @prototype = FactoryBot.build(:prototype)
  end

  describe '新規投稿' do
    context '新規投稿できる' do
      it '必要な情報が揃っていれば投稿できる' do
        expect(@prototype).to be_valid
      end
    end

    context '投稿できない' do
      it 'プロトタイプの名称が入力されていなければ投稿できない' do
        @prototype.title = ''
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Title can't be blank")
      end
      it 'キャッチコピーが入力されていなければ投稿できない' do
        @prototype.catch_copy = ''
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Catch copy can't be blank")
      end
      it 'コンセプトが入力されていなければ投稿できない' do
        @prototype.concept = ''
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Concept can't be blank")
      end
      it '画像が1枚も添付されていなければ投稿できない' do
        @prototype.image = nil
        @prototype.valid?
        expect(@prototype.errors.full_messages).to include("Image can't be blank")
      end
    end
  end
end
