class AddColumnToComment < ActiveRecord::Migration[6.0]
  def change
    add_reference :comments, :user,      null: false, foreign_key: true
    add_reference :comments, :prototype, null: false, foreign_key: true
  end
end
