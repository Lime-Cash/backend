2000.times do |i|
  user = User.create!(
    name: "Test User #{i + 1}",
    email: "testuser#{i + 1}@test.com",
    password: "Password123!",
  )
  user.create_account(balance: 0)
end
