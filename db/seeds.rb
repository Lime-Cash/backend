john_user = User.create!(name: "John Doe", email: "johndoe@mail.com", password: "password")
mary_user = User.create!(name: "Mary Doe", email: "marydoe@mail.com", password: "password")

mary_account = mary_user.create_account(balance: 100)
john_account = john_user.create_account(balance: 100)

Transfer.create!(from_account: john_account, to_account: mary_account, amount: 10)
Transfer.create!(from_account: mary_account, to_account: john_account, amount: 10)
