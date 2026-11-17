class CreatePractitioners < ActiveRecord::Migration[8.0]
  def change
    create_table :practitioners do |t|
      t.string :name, null: false
      t.string :specialty

      t.timestamps
    end
  end
end
