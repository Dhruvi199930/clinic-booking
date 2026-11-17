class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointments do |t|
      t.references :practitioner, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :duration_minutes, null: false, default: 30
      t.text :notes

      t.timestamps
    end
    add_index :appointments, [ :practitioner_id, :starts_at ]
  end
end
