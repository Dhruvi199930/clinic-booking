class AddOverlapTriggerToAppointments < ActiveRecord::Migration[8.0]
  # The model validation catches overlaps for normal use, but two requests
  # can both pass it before either one inserts. SQLite runs writes one at a
  # time, so a trigger closes that gap.
  def up
    execute <<~SQL
      CREATE TRIGGER appointments_no_overlap_insert
      BEFORE INSERT ON appointments
      WHEN EXISTS (
        SELECT 1 FROM appointments
        WHERE practitioner_id = NEW.practitioner_id
          AND starts_at < NEW.ends_at
          AND ends_at > NEW.starts_at
      )
      BEGIN
        SELECT RAISE(ABORT, 'appointment_overlap');
      END;
    SQL

    execute <<~SQL
      CREATE TRIGGER appointments_no_overlap_update
      BEFORE UPDATE OF practitioner_id, starts_at, ends_at ON appointments
      WHEN EXISTS (
        SELECT 1 FROM appointments
        WHERE practitioner_id = NEW.practitioner_id
          AND id != NEW.id
          AND starts_at < NEW.ends_at
          AND ends_at > NEW.starts_at
      )
      BEGIN
        SELECT RAISE(ABORT, 'appointment_overlap');
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS appointments_no_overlap_insert"
    execute "DROP TRIGGER IF EXISTS appointments_no_overlap_update"
  end
end
