1# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
client = Client.create!(
  first_name: "Axel",
  last_name: "Alvarade",
  address: "12 rue du zinc, 75000 Paris",
  user_id: 1
)

user = User.create!(
  first_name: "Axel",
  last_name: "Alvarade",
  email: "charles.de.fontenay@gmail.com",
  encrypted_password: "helloestimio"
)
