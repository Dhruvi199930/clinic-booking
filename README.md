# clinic-booking

Small Rails app for booking appointments at a clinic. You can add patients, book them in with a practitioner, see each practitioner's schedule, and cancel appointments. It won't let you double-book a practitioner.

I mostly work in React and wanted to actually learn Rails, so I picked something close to a real problem: clinic scheduling.

## Running it locally

You need Ruby 3.4.

```
bundle install
bin/rails db:setup
bin/rails server
```

Then go to localhost:3000. `db:setup` adds a few fake practitioners and patients with appointments booked for tomorrow.

To run the tests: `bin/rails test`

## The double-booking check

Two appointments overlap if one starts before the other ends and ends after the other starts:

```ruby
.where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
```

I store `ends_at` on the appointment instead of calculating it from `duration_minutes` inside the query. Date math is written differently in SQLite and Postgres, so this keeps the query simple, and it can use the index on `(practitioner_id, starts_at)`.

Since it's `<` and `>` and not `<=`, back-to-back bookings are allowed (one ends at 10:30, the next starts at 10:30).

## What's missing

- The overlap check is a model validation, so two requests at the exact same moment could both get through. Postgres exclusion constraints would fix this at the database level.
- No login, anyone can book or cancel
- No working hours, so you can book someone at 3am
- Everything is in Pacific time

Next I want to add working hours for each practitioner, then email reminders with Active Job.
