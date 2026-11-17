# Clinic Booking

A small Rails app for booking appointments at a clinic. Practitioners have schedules, patients book time slots, and the app won't let two appointments overlap for the same practitioner.

## Running it

Needs Ruby 3.3+.

```
bundle install
bin/rails db:setup
bin/rails server
```

Then open http://localhost:3000. `db:setup` loads some sample practitioners, patients and appointments for tomorrow.

Tests:

```
bin/rails test
```

## How double-booking is prevented

Each appointment stores `starts_at` and `ends_at`. Two appointments clash if one starts before the other ends and ends after the other starts:

```ruby
.where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
```

I store `ends_at` instead of working it out from `duration_minutes` in the query. Date math in SQL looks different in SQLite and Postgres, and this way the check is just a comparison that can use the `(practitioner_id, starts_at)` index.

Back-to-back appointments (one ends at 10:30, the next starts at 10:30) are allowed because the comparison is strict.

## Known gaps

- The overlap check is a validation, so two requests landing at the exact same moment could both pass. A real version would need a database-level constraint (Postgres exclusion constraint) or a lock.
- No logins. Anyone can book or cancel.
- No working hours. You can book someone at 3am.
- Single time zone (Pacific).

## What I'd add next

- Practitioner availability (working hours, days off)
- Patients booking for themselves
- Email reminders with Active Job
