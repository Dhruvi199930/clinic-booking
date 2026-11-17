CREATE TABLE IF NOT EXISTS "patients" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "email" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_patients_on_email" ON "patients" ("email");
CREATE TABLE IF NOT EXISTS "practitioners" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "specialty" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "day_starts_at_hour" integer DEFAULT 9 NOT NULL, "day_ends_at_hour" integer DEFAULT 17 NOT NULL, "works_weekends" boolean DEFAULT 0 NOT NULL, "time_zone" varchar DEFAULT 'Pacific Time (US & Canada)' NOT NULL);
CREATE TABLE IF NOT EXISTS "appointments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "practitioner_id" integer NOT NULL, "patient_id" integer NOT NULL, "starts_at" datetime(6) NOT NULL, "ends_at" datetime(6) NOT NULL, "duration_minutes" integer DEFAULT 30 NOT NULL, "notes" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c63da04ab4"
FOREIGN KEY ("patient_id")
  REFERENCES "patients" ("id")
, CONSTRAINT "fk_rails_e4380ad6f7"
FOREIGN KEY ("practitioner_id")
  REFERENCES "practitioners" ("id")
);
CREATE INDEX "index_appointments_on_patient_id" ON "appointments" ("patient_id");
CREATE INDEX "index_appointments_on_practitioner_id_and_starts_at" ON "appointments" ("practitioner_id", "starts_at");
CREATE INDEX "index_appointments_on_practitioner_id" ON "appointments" ("practitioner_id");
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
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
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "email" varchar NOT NULL, "password_digest" varchar NOT NULL, "time_zone" varchar DEFAULT 'Pacific Time (US & Canada)' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
INSERT INTO "schema_migrations" (version) VALUES
('20261117171148'),
('20261117163025'),
('20261117160412'),
('20261104012237'),
('20261103195208'),
('20261103194512');

