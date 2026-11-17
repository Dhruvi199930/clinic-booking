User.find_or_create_by!(email: "desk@clinic.test") do |user|
  user.name = "Front Desk"
  user.password = "password"
end

ana  = Practitioner.find_or_create_by!(name: "Dr. Ana Reyes")  { |p| p.specialty = "Physiotherapy" }
ben  = Practitioner.find_or_create_by!(name: "Ben Okafor")     { |p| p.specialty = "Massage therapy" }
mira = Practitioner.find_or_create_by!(name: "Mira Chen") do |p|
  p.specialty = "Chiropractic"
  p.day_starts_at_hour = 7
  p.day_ends_at_hour = 15
  p.works_weekends = true
end

patients = [
  [ "Sam Lee", "sam@example.com" ],
  [ "Priya Nair", "priya@example.com" ],
  [ "Tom Becker", "tom@example.com" ],
  [ "Lucia Ortiz", "lucia@example.com" ]
].map do |name, email|
  Patient.find_or_create_by!(email: email) { |p| p.name = name }
end

if Appointment.none?
  day = Time.zone.today.next_weekday.in_time_zone

  [
    [ ana,  patients[0], 9,  0,  30 ],
    [ ana,  patients[1], 9,  30, 45 ],
    [ ben,  patients[2], 10, 0,  60 ],
    [ mira, patients[3], 13, 15, 30 ]
  ].each do |practitioner, patient, hour, min, length|
    Appointment.create!(
      practitioner: practitioner,
      patient: patient,
      starts_at: day.change(hour: hour, min: min),
      duration_minutes: length
    )
  end
end
