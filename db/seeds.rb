2000.times do |i|
  user = User.create!(
    name: "Test User #{i + 1}",
    email: "testuser#{i + 1}@test.com",
    password: "Password123!",
  )
  user.create_account(balance: 0)
end

if Rails.env.development?
  # Create specific test users
  john_doe = User.create!(name: "John Doe", email: "johndoe@mail.com", password: "Password123!")
  john_doe.create_account(balance: 1000.0)

  mary_doe = User.create!(name: "Mary Doe", email: "marydoe@mail.com", password: "Password123!")
  mary_doe.create_account(balance: 1000.0)

  puts "Created #{User.count} users with accounts"
  puts "John Doe: #{john_doe.email}"
  puts "Mary Doe: #{mary_doe.email}"
end
