# clinic-booking

Rails app for booking appointments at a clinic. Front desk staff log in, add patients, book them in with a practitioner, and cancel. It won't let you double-book a practitioner or book them outside their working hours, and patients get an email reminder the day before.

I mostly work in React and wanted to actually learn Rails, so I picked something close to a real problem: clinic scheduling.

## Running it locally

You need Ruby 3.4 and the `sqlite3` command line tool (macOS already has it).

```
bundle install
bin/rails db:setup
bin/rails server
```

Then go to localhost:3000 and log in with `desk@clinic.test` / `password`. `db:setup` adds a few fake practitioners and patients with appointments on the next weekday.

To run the tests: `bin/rails test`

Reminder emails don't actually get sent in development. They're written to `tmp/mails` so you can read them.

## Double-booking

Two appointments overlap if one starts before the other ends and ends after the other starts:

```ruby
.where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
```

I store `ends_at` on the appointment instead of calculating it from `duration_minutes` inside the query. Date math is written differently in SQLite and Postgres, so this keeps the query simple, and it can use the index on `(practitioner_id, starts_at)`.

Since it's `<` and `>` and not `<=`, back-to-back bookings are allowed (one ends at 10:30, the next starts at 10:30).

The model validation alone isn't enough though. Two requests can both check, both see the slot is free, and both insert. So there's also a SQLite trigger that runs the same check on insert and update and aborts if there's a clash. SQLite only does one write at a time, so the second insert always sees the first. `Appointment#save` catches that error and turns it into the same "already booked" message the form shows normally.

Because of the trigger the schema is kept in `db/structure.sql` instead of `schema.rb`, since `schema.rb` can't store triggers.

## Working hours and time zones

Each practitioner has a start hour, an end hour, whether they work weekends, and their own time zone. Hours are checked in the practitioner's zone, so if someone in Toronto works 9 to 5, a booking made from Vancouver at 7am still lands at 10am for them and is allowed.

Times are stored in UTC. Each staff member picks the zone they want to see times in (click your name in the top bar), and every page is rendered in that zone.

## Login

Plain `has_secure_password` with the user id in the session. The session is reset on login and logout, and login attempts are rate limited to 10 every 3 minutes. Every page except the login page needs you to be logged in.

## Reminders

When an appointment is booked, a job is scheduled for 24 hours before it starts (or right away if it's sooner than that). The job takes the appointment id instead of the record, so if the appointment gets cancelled in the meantime the job just finds nothing and skips it.

## What's missing

- The trigger is SQLite specific. On Postgres I'd swap it for an exclusion constraint on a time range.
- Jobs use Rails' default in-process adapter, so scheduled reminders are lost if the server restarts. In production this should be Solid Queue or Sidekiq.
- No email provider is set up for production.
- Every staff login can do everything. No roles.
- Working hours are one block per day, so no lunch breaks or days off.
- No recurring appointments.
