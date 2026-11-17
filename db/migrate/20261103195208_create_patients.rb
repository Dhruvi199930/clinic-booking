class CreatePatients < ActiveRecord::Migration[8.0]
  def change
    create_table :patients do |t|
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end
    add_index :patients, :email, unique: true
  end
end
