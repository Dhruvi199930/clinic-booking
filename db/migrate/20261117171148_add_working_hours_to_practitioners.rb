class AddWorkingHoursToPractitioners < ActiveRecord::Migration[8.0]
  def change
    add_column :practitioners, :day_starts_at_hour, :integer, null: false, default: 9
    add_column :practitioners, :day_ends_at_hour, :integer, null: false, default: 17
    add_column :practitioners, :works_weekends, :boolean, null: false, default: false
    add_column :practitioners, :time_zone, :string, null: false, default: "Pacific Time (US & Canada)"
  end
end
